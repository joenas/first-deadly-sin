# frozen_string_literal: true

require 'rspotify'
RSpotify.authenticate(ENV['SPOTIFY_CLIENT_ID'], ENV['SPOTIFY_CLIENT_SECRET'])

class FirstSin < Sinatra::Base
  not_found { haml :'404' }
  error do
    @error = request.env['sinatra.error']
    haml :'500'
  end

  get '/info' do
    content_type :json
    $mpd.info.to_json
  end

  post '/command' do
    content_type :json
    command = params[:action]
    if command == 'pause'
      res = $mpd.send(:pause=, !$mpd.paused?)
    elsif command
      res = $mpd.send command
    end
    { success: res }.to_json
  end

  post '/volume' do
    content_type :json
    volume = $mpd.send(params[:vol], 5)
    { volume: volume }.to_json
  end

  get '/playlist' do
    content_type :json
    $mpd.playlists.map(&:name).to_json if $mpd.connected?
  end

  get '/image' do
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
