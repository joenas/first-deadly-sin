class FirstSin < Sinatra::Base
  get '/mpd.json' do
    content_type :json
    if command = params[:action]
      $mpd.send command
    elsif vol_change = params[:vol]
      mpd_volume vol_change
    end
    mpd_info.to_json
  end

  get '/image.json' do
    content_type :json
    if artist = params[:artist]
      image = ImageFetcher.new(artist, settings.images, $redis).fetch
      url = "images/artists/#{image}"
    end
    {:url => url, :image => image}.to_json
  end

  put '/image.json' do
    content_type :json
    if params[:image]
      artist, image = params[:image].split("/")
      status = ImageHandler.new(artist, image, settings.images).favorite
    end
    {:status => status}.to_json
  end

  delete '/image.json' do
    content_type :json
    if params[:image]
      artist, image = params[:image].split("/")
      status = ImageHandler.new(artist, image, settings.images).remove
    end
    {:status => status}.to_json
  end

  get '/mpd/playlist.json' do
    content_type :json

    $mpd.playlist.map do |file|
      {
        :artist => file.artist,
        :title => file.title,
        :album => file.album,
        :id => file.id,
      }
    end.to_json if $mpd.active?
  end

  # just for testing
  get '/commands.json' do
    content_type :json
    $mpd.controller.commands.inspect.to_json
  end

  get '/*' do
    haml :index
  end
end