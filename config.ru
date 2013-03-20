require 'logger'
require 'rubygems'
require 'bundler'
Bundler.require
Dir[File.dirname(__FILE__) + '/lib/*'].each {|file| require file }
require './first_sin'

$stderr.sync = $stdout.sync = true
$logger = Logger.new STDOUT
$logger.level = Logger::INFO
$logger.formatter = proc do |severity, datetime, progname, msg|
  "#{MPD_HOST} - - [#{datetime.strftime("%d/%b/%Y %H:%M:%S")}] [#{severity}] #{msg}\n"
end

FAYE_SERVER_URL = ENV['FAYE_SERVER_URL'] || 'http://localhost:9292/faye'
MPD_HOST = ENV['MPD_HOST'] || '10.0.0.12'
MPD_PORT = ENV['MPD_PORT'] || 6600
MPD_CONNECTION_TIMEOUT = "MPD connection timeout, is MPD running?"
MPD_CONNECTION_REFUSED = "MPD connection refused, is MPD running?"

begin
  $mpd = MPD.new MPD_HOST, MPD_PORT
  $mpd.connect
  $logger.info('MPD - Connected')
rescue Errno::ETIMEDOUT => error
  $logger.error MPD_CONNECTION_TIMEOUT and exit 1
rescue Errno::ECONNREFUSED => error
  $logger.error MPD_CONNECTION_REFUSED and exit 1
end

Supervisor.supervise MPDListener, :as => :listener,  :args => [$mpd]
Supervisor.supervise Publisher, :as => :publisher, :args => [FAYE_SERVER_URL]
supervisor = Supervisor.run!

publisher = Celluloid::Actor[:publisher]
listener = Celluloid::Actor[:listener]

listener.on :song do
  song = $mpd.current_song
  $logger.info "MPD - #{song.artist} - #{song.title}"
  publisher.async.publish('/first-sin/mpd', { info: $mpd.info, action: "mpd" } )
end

listener.on :state do |state|
  $logger.info "MPD - #{state}"
  publisher.async.publish('/first-sin/mpd', { info: $mpd.info, action: "mpd" } )
end

listener.async.run

trap('INT') do
  supervisor.finalize
  puts ">> Stopping ..."
  exit 0
end

run FirstSin
