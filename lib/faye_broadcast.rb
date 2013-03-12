module FayeBroadcast
  # Faye broadcast!
  # from http://railscasts.com/episodes/260-messaging-with-faye
  def broadcast(channel, data)
    message = { channel: channel, data: data }
    uri = URI.parse( DasBoot::FAYE_SERVER_URL )
    Net::HTTP.post_form(uri, :message => message.to_json)
  end
end