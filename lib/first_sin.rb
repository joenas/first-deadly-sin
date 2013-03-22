module FirstSin
  class << self
    MPD_ERROR = "MPD connection failed: "

    def configure
      yield config if block_given?
    end

    def config
      @config ||= Configuration.new
    end

    def run
      connect_mpd
      run_actors
      setup_callbacks
    end

    def logger
      config[:logger]
    end

  private
    def connect_mpd
      begin
        $mpd = MPD.new *config[:mpd_conf]
        $mpd.connect
        logger.info('MPD - Connected')
      rescue => error
        logger.error "#{MPD_ERROR} #{error.message}" and exit 1
      end
    end

    def run_actors
      Publisher.supervise_as :publisher, config[:faye_server_url]
      MPDListener.supervise_as :listener,  $mpd, Celluloid::Actor[:publisher], config[:mpd_events]
    end

    def setup_callbacks
      config[:callbacks].each do |event, block|
        Celluloid::Actor[:publisher].on(event, &block)
      end
    end
  end
end