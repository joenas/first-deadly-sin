class Configuration
  attr_writer :mpd_host, :mpd_port, :logger
  def initialize
    @logger = Logger.new STDOUT
    @mpd_host = ENV['MPD_HOST'] || 'localhost'
    @mpd_port = ENV['MPD_PORT'] || 6600
    @faye_server_url = ENV['FAYE_SERVER_URL'] || 'http://localhost:9292/faye'
  end

  def [](config_item)
    instance_variable_get("@#{config_item.to_s}")
  end
end
