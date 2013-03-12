class FirstSin < Sinatra::Base
  get %r{/mpd/?(.*).json} do |command|
    content_type :json

    unless command.empty?
      $mpd.do command
      broadcast('/foo', { text: "MPD #{command}", action: "mpd" } )
    end

    $mpd.info.to_json
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
    puts $mpd.info[:volume]
    puts derp = $mpd.controller.commands.inspect
    derp.to_json
   # $mpd.commands.to_json
  end

  get '/*' do
    haml :index
  end
end
