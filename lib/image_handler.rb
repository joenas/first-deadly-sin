require 'redis'
class ImageHandler
  def initialize(artist, image, base_path, redis = Redis.new)
    @base_path = base_path
    @artist = artist
    @image = image
    @redis = redis
    @new_key = "artists:#{@artist}:images:new"
    @favorites_key = "artists:#{@artist}:images:favorites"
  end

  def favorite
    if @redis.srem(@new_key, @image)
      @redis.sadd @favorites_key, @image
    else
      false
    end
  end

  def remove
    if @redis.srem(@new_key, @image)
      file = File.join(@base_path, @artist, @image)
      File.delete(file) if File.exists?(file)
      true
    else
      false
    end
  end
end

# path = File.expand_path(File.join(File.dirname(__FILE__), '../app/images/artists'))
# puts ImageHandler.new('mum', '3c7d8d6c-5692-48a7-a49e-21d0b6201e38.jpg', path).remove