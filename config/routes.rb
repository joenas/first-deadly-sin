class FirstSin < Sinatra::Base
  get '/mpd.json' do
    content_type :json
    if command = params[:action]
      $mpd.do command
      broadcast('/first-sin/mpd', { text: "MPD #{command}", action: "mpd" } )
    elsif vol_change = params[:vol]
      $mpd.vol vol_change
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
