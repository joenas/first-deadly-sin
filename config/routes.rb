# frozen_string_literal: true

class FirstSin < Sinatra::Base
  not_found { haml :'404' }
  error do
    @error = request.env['sinatra.error']
    haml :'500'
  end

  get '/mpd.json' do
    content_type :json
    command = params[:action]
    vol_change = params[:vol]
    if command == 'pause'
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
    if $mpd.active?
      $mpd.playlist.map do |file|
        {
          artist: file.artist,
          title: file.title,
          album: file.album,
          id: file.id
        }
      end.to_json
    end
  end

  get '/' do
    haml :index
  end
end
