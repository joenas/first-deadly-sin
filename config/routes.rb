class FirstSin < Sinatra::Base
  get '/mpd.json' do
    content_type :json

    if command = params[:action]
      $mpd.do command
      broadcast('/first-sin/mpd', { text: "MPD #{command}", action: "mpd" } )
    end

    $mpd.info.to_json
  end

  get '/image.json' do
    content_type :json
    if artist = params[:artist]
      image = ImageFetcher.new(artist, settings.images, $redis).fetch
      url = "images/artists/#{image}"
    end
    {:url => url, :image => image}.to_json
  end

  get '/favorite.json' do
    content_type :json
    if params[:image]
      artist, image = params[:image].split("/")
      status = ImageHandler.new(artist, image, settings.images).favorite
    end
    {:status => status}.to_json
  end

  get '/remove.json' do
    content_type :json
    if params[:image]
      artist, image = params[:image].split("/")
      status = ImageHandler.new(artist, image, settings.images).remove
    end
    {:status => status}.to_json
  end

  get '/volume.json' do
    $mpd.vol params[:vol]
    $mpd.info.to_json
  end

  get '/playlist.json' do
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

  get '/commands.json' do
    content_type :json
    $mpd.controller.commands.inspect.to_json
  end

  get '/*' do
    haml :index
  end
end