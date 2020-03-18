class FirstSin < Sinatra::Base
  not_found { haml :'404' }
  error { @error = request.env['sinatra.error'] ; haml :'500' }

  get '/mpd.json' do
    content_type :json
    command = params[:action]
    vol_change = params[:vol]
    if command == 'pause'
      puts 'paused', $mpd.paused?
      $mpd.send(:pause=, !$mpd.paused?)
    elsif command
      $mpd.send command
    elsif vol_change
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

  get '/' do
    haml :index
  end
end
