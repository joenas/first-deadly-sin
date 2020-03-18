# frozen_string_literal: true

require 'rubygems'
require 'bundler'
Bundler.require
require './lib/mpd_info'
require './first_sin'
require 'logger'

$stdout.sync = true

FAYE_SERVER_URL = ENV['FAYE_SERVER_URL'] || 'http://localhost:9292/faye'

# MPD
MPD_HOST = ENV['MPD_HOST'] || 'localhost'
MPD_PORT = ENV['MPD_PORT'] || 6600
MPD_CONNECTION_TIMEOUT = 'MPD connection timeout, is MPD running?'
MPD_CONNECTION_REFUSED = 'MPD connection refused, is MPD running?'

$mpd = MPD.new MPD_HOST, MPD_PORT, { callbacks: true }

# Logging
$logger = Logger.new STDOUT
$logger.level = Logger::INFO
$logger.formatter = proc do |severity, datetime, _progname, msg|
  date_formatted = datetime.strftime('%d/%b/%Y %H:%M:%S')
  "#{MPD_HOST} - - [#{date_formatted}] [#{severity}] #{msg}\n"
end

# Faye
faye = Faye::Client.new(FAYE_SERVER_URL)

faye.bind('transport:up') do
  $logger.info 'Faye - connected'
end

faye.bind('transport:down') do
  $logger.error 'Faye - disconnected'
end

# MPD
begin
  $mpd.connect
  $logger.info "MPD - connected, version #{$mpd.version}"
rescue Errno::ETIMEDOUT
  abort MPD_CONNECTION_TIMEOUT
rescue Errno::ECONNREFUSED
  abort MPD_CONNECTION_REFUSED
end

$mpd.on :song do |song|
  $logger.info "MPD - song: #{song.artist} - #{song.title}" if song
  faye&.publish('/first-sin/mpd', { info: $mpd.info, action: 'mpd' })
end

$mpd.on :state do |state|
  $logger.info "MPD - state: #{state}"
  faye&.publish('/first-sin/mpd', { info: $mpd.info, action: 'mpd' })
end

$mpd.on :connection do |connection|
  $logger.info "MPD - connection: #{connection}"
  faye&.publish('/first-sin/mpd', { info: $mpd.info, action: 'mpd' })
end

trap('INT') do
  puts 'Exiting'
  $mpd.disconnect if $mpd.connected?
  exit 0
end

run FirstSin
