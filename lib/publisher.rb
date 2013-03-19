require 'open-uri'
require 'net/http'
require 'json'

class Publisher
  include Celluloid

  def initialize(url)
    @url = url
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
end