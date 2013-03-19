require 'celluloid'
require 'celluloid/io'
require 'ruby-mpd'
require 'faye'
require './lib/mpd_info'
require 'open-uri'
require 'net/http'
require 'json'
# require 'sinatra'
# require 'sinatra/reloader'
# require 'sinatra/assetpack'
#require './first_sin'
$stdout.sync = true

class Listener
  include Celluloid#::IO

  def initialize(connection, publisher)
    @connection = connection
    @publisher = publisher
    @callbacks = {}
  end

  def listen
    old_status = {}
    while true
      status = @connection.status
      changed_keys = Hash[(status.to_a - old_status.to_a)].keys
      #@publisher.publish 'mpd', changed_keys

      changed_keys.each {|key|
        if @callbacks[key]
          @callbacks[key].each {|callback|
            callback.call(key)
          }
        end
      }

      old_status = status
      sleep 0.1
    end
  end

  def on(event, &block)
    @callbacks[event] ||= []
    @callbacks[event].push block
  end
end

class Publisher
  include Celluloid
  def initialize(url)
    @url = url
  end

  def publish(channel, data)
    message = { channel: channel, data: data }
    uri = URI.parse( @url )
    Net::HTTP.post_form(uri, :message => message.to_json)
  end
end

class Derp
  include Celluloid
  def publish(channel, msg)
    puts "#{channel}: #{msg}"
  end
end

FAYE_SERVER_URL = ENV['FAYE_SERVER_URL'] || 'http://localhost:9292/faye'


mpd = MPD.new
mpd.connect
#faye = Faye::Client.new(FAYE_SERVER_URL)
publisher = Publisher.new(FAYE_SERVER_URL)

listener = Listener.new(mpd, publisher)
listener.on :song do |event|
  publisher.publish!('/first-sin/mpd', { info: mpd.info, action: "mpd" } )
end
listener.listen!

trap('INT') do
  puts 'derp'
  exit 0
end

sleep
#FirstSin.run