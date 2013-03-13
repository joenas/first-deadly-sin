require 'securerandom'
require 'redis'
require 'open-uri'
require 'json'
require_relative 'image_worker'

# Fetch the new images from Last FM!
class ImageFetcher

  API_KEY = "e37be5627a5ca3106743f138b2220f12"
  AS_URI = "http://ws.audioscrobbler.com/2.0/?format=json&method=artist.getimages&artist=%s&api_key=#{API_KEY}"

  def initialize(artist, base_path, redis = Redis.new)
    @base_path = base_path
    @artist = artist.downcase.gsub(' ', '_')
    @artist_encoded = URI::encode(artist)
    @redis = redis
    @key = "artists:#{@artist}:images:new"
    @image = nil
  end

  def fetch
    fetch_new_images unless @redis.scard(@key) > 0
    image = @image || @redis.srandmember(@key)
    "#{@artist}/#{image}"
  end

  def fetch_and_persist(url)
    path = "#{@base_path}/#{@artist}"
    file_name = "#{SecureRandom.uuid}.jpg"
    persist_to_file(url, file_name, path)
    insert_to_redis(file_name)
    return file_name
  end

private
  def fetch_new_images
    response = JSON.parse(open(AS_URI % @artist_encoded).read)
    urls = response['images']['image'].map { |image| image['sizes']['size'].first['#text'] }
    @image = fetch_and_persist(urls.pop)
    fetch_async(urls)
  end

  def fetch_async(urls)
    urls.each_slice(10) {|url_slice|
      ImageWorker.perform_async(@artist, @base_path, url_slice)
    }
  end

  def persist_to_file(url, file_name, path)
    Dir.mkdir(path) unless File.exists?(path)
    open("#{path}/#{file_name}", "wb") do |file|
      open(url) do |uri|
        file.write(uri.read)
        file.close
      end
    end
  end

  def insert_to_redis(file_name)
    @redis.sadd @key, file_name
  end
end

# path = File.expand_path(File.join(File.dirname(__FILE__), '../app/images/artists'))
# image =ImageFetcher.new('kid 606', path).fetch
# puts image
