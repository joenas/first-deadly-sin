class MPDListener
  include Celluloid

  def initialize(mpd, publisher, monitored_events = [])
    @mpd = mpd
    @monitored_events = monitored_events
    @publisher = publisher
    async.run
  end

  def run
    connect unless @mpd.connected?
    listen({})
  end

private
  def listen(old_status)
    listen @mpd.status.tap{ |stat|
      emit_events (stat.to_a - old_status.to_a).map(&:first)
      sleep 0.2
    }
  end

  def emit_events(events)
    @publisher.mailbox << events & @monitored_events
  end

  def disengage!
    $logger.error('MPD - Cannot reconnect, aborting')
    Celluloid.shutdown and exit 1
  end

  def connect
    after(30) do
      disengage! unless @mpd.connected?
    end
    $logger.info('MPD - Trying to connect')
    @mpd.connect
    $logger.info('MPD - Connected!')
  rescue Errno::ECONNREFUSED => error
    sleep 2
    retry
  end
end