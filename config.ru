require 'logger'
require 'rubygems'
require 'bundler'
Bundler.require
Dir[File.dirname(__FILE__) + '/lib/*'].each {|file| require file }

$stderr.sync = $stdout.sync = true

FirstSin.configure do |config|
  config.faye_server_url = 'http://localhost:9292/faye'
  #config.mpd_host = 'localhost'
  #config.mpd_port = 6600
  config.mpd_events = [:state, :song]
  config.logger.formatter = proc do |severity, datetime, progname, msg|
     "#{config[:mpd_host]} - - [#{datetime.strftime("%d/%b/%Y %H:%M:%S")}] [#{severity}] #{msg}\n"
  end

  config.publisher :on => :song do |publisher|
    info = $mpd.info
    FirstSin.logger.info "MPD - [Song] #{info[:artist]} - #{info[:title]}"
    publisher.async.publish('/first-sin/mpd', { info: info, action: "mpd" } )
  end

  config.publisher :on => :state do |publisher|
    info = $mpd.info
    FirstSin.logger.info "MPD - [State] #{info[:state]}"
    publisher.async.publish('/first-sin/mpd', { info: info, action: "mpd" } )
  end
end

trap('INT') do
  Celluloid.shutdown
  puts ">> Stopping ..."
  exit 0
end

begin
  FirstSin.run
  run FirstSin::WebApp
rescue Exception => error
  FirstSin.logger.error "ERROR: #{error.message}"
  FirstSin.shutdown
end