class ImageWorker
      # images.each do |image|
    #   image_url = image['sizes']['size'].first['#text']
    #   id = SecureRandom.uuid
    #   path = "images/#{artist}"
    #   write_to_file(image_url, "#{id}.jpg", path)
    #   redis.sadd "artists:#{artist}:images:new", id
    # end

def write_to_file(url, file_name, path)
  Dir.mkdir(path) unless File.exists?(path)
  open("#{path}/#{file_name}", "wb") do |file|
    open(url) do |url|
      file.write(url.read)
      file.close
    end
  end
end
end