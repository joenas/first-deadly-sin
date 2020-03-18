# frozen_string_literal: true

require 'rspotify'
RSpotify.authenticate(ENV['SPOTIFY_CLIENT_ID'], ENV['SPOTIFY_CLIENT_SECRET'])

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
    $mpd.playlists.map(&:name).to_json if $mpd.connected?
  end

  get '/artist.json' do
    content_type :json
    artists = RSpotify::Artist.search(CGI.unescape(params[:artist]))
    return if !artists || artists.empty?

    artist = artists.first
    unless artist.images.empty?
      sorted = artist.images.sort { |a, b| a[:width] <=> b[:width] }
      sorted.first.to_json
    end
  end

  get '/' do
    haml :index
  end
end
