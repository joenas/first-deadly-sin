class Configuration
  attr_writer :mpd_host, :mpd_port, :mpd_events, :logger, :faye_server_url
  attr_reader :logger

  ITEMS = [ :mpd_host, :mpd_port, :mpd_events, :mpd_conf,
            :logger, :faye_server_url, :callbacks ]

  def initialize
    @logger = Logger.new STDOUT
    @mpd_host = ENV['MPD_HOST'] || 'localhost'
    @mpd_port = ENV['MPD_PORT'] || 6600
    @mpd_events = []
    @mpd_conf = [@mpd_host, @mpd_port]
    @faye_server_url = ENV['FAYE_SERVER_URL'] || 'http://localhost:9292/faye'
    @callbacks = []
  end

  def [](config_item)
    instance_variable_get("@#{config_item.to_s}") if ITEMS.include? config_item
  end

  def publisher(option, &block)
    @callbacks << [option[:on], block]
  end
end
