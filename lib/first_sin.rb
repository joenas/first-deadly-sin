module FirstSin
  class << self
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

    def shutdown
      # Ugly hack to shutdown Faye
      %x[lsof -i :9292 -t].split("\n").each { |pid|
        %x[kill -9 #{pid}] if %x[cat /proc/#{pid}/cmdline] =~ /rackup/
      }
      Celluloid.shutdown
      exit 1
    end

  private
    def connect_mpd
      $mpd = MPD.new *config[:mpd_conf]
      $mpd.connect
      logger.info('MPD - Connected')
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