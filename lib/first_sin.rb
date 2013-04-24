module FirstSin
  class ShutdownError < StandardError; end

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
    rescue FirstSin::ShutdownError => error
      logger.error "#{error.message}: #{caller.first}"
      shutdown
    end

    def logger
      config[:logger]
    end

    def shutdown(success = false)
      logger.info ">> Shutting down"
      #shutdown_faye
      Celluloid.shutdown
      exit success
    end

  private
    def connect_mpd
      $mpd = MPD.new(config[:mpd_host], config[:mpd_port])
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

    def shutdown_faye
      # Ugly hack to shutdown Faye
      %x[lsof -i :9292 -t].split("\n").each do |pid|
        %x[kill -9 #{pid}] if %x[cat /proc/#{pid}/cmdline] =~ /rackup/
      end
    end
  end
end