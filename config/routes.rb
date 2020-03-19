# frozen_string_literal: true

require 'rspotify'
RSpotify.authenticate(ENV['SPOTIFY_CLIENT_ID'], ENV['SPOTIFY_CLIENT_SECRET'])

class FirstSin < Sinatra::Base
  not_found {}

  # TODO: better way? for React
  before do
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Headers'] = 'accept, authorization, origin'
  end

  options '*' do
    response.headers['Allow'] = 'HEAD,GET,PUT,DELETE,OPTIONS,POST'
    response.headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept'
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
    status 404
    artist_name = CGI.unescape(params[:artist])
    artists = RSpotify::Artist.search(artist_name)
    return if !artists || artists.empty?

    artist = artists.first
    unless artist.images.empty?
      status 200
      sorted = artist.images.sort { |a, b| a[:width] <=> b[:width] }
      sorted.first.to_json
    end
  end

  get '/' do
    send_file File.join(settings.public_folder, 'index.html')
  end
end
