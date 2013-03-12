require 'redis'
require 'open-uri'
require 'json'

class ImageFetcher

  API_KEY = "e37be5627a5ca3106743f138b2220f12"
  AS_URI = "http://ws.audioscrobbler.com/2.0/?format=json&method=artist.getimages&artist=%s&api_key=#{API_KEY}"


  def initialize(redis = Redis.new)
    @redis = redis
  end

  def fetch(artist)
    @key = "artists:#{artist}:images:new"
    fetch_new_images(artist) unless @redis.scard(@key) < 0
    image = @redis.srandmember @key
  end

  def fetch_new_images(artist)
    response = JSON.parse(open(AS_URI % artist).read)
    images = response['images']['image']
    urls = images.map { |image| image['sizes']['size'].first['#text'] }
    urls.each_slice(10) {|slice|
      puts "a slice!"
      puts slice
    }
  end
end
