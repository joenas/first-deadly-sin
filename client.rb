# frozen_string_literal: true

# Just for testing Faye and see that the apps sends its messages

require 'faye'
require 'eventmachine'
FAYE_SERVER_URL = ENV['FAYE_SERVER_URL'] || 'http://localhost:9292/faye'
faye = Faye::Client.new(FAYE_SERVER_URL)

EM.run do
  faye.subscribe('/first-sin/mpd') do |message|
    puts message.inspect
  end
end
