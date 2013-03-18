class FirstSin < Sinatra::Base
  get '/mpd.json' do
    content_type :json
    if command = params[:action]
      $mpd.send command
    elsif vol_change = params[:vol]
      $mpd.send(vol_change, 5)
    end
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

  get '/*' do
    haml :index
  end
end
