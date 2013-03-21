require 'open-uri'
require 'net/http'
require 'json'

class Publisher
  include Celluloid

  def initialize(url)
    @url = url
    @callbacks = {}
    async.publish_events
  end

  def publish_events
    loop {trigger_callbacks receive}
  end

  def publish(channel, data)
    begin
      message = { channel: channel, data: data }
      uri = URI.parse( @url )
      Net::HTTP.post_form(uri, :message => message.to_json)
    rescue Errno::ECONNREFUSED => error
      $logger.error("Faye - Connection refused at #{uri}")
    end
  end

  def on(event, &block)
    @callbacks[event] ||= []
    @callbacks[event].push block
  end

private
  def trigger_callbacks(events)
    events.each do |event|
      perform_callbacks event if @callbacks[event]
    end
  end

  def perform_callbacks(event)
    @callbacks[event].each do |callback|
      callback.call self
    end
  end
end