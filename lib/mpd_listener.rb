class MPDListener
  include Celluloid

  def initialize(mpd, publisher, monitored_events = [])
    @mpd = mpd
    @monitored_events = monitored_events
    @publisher = Celluloid::Actor[publisher]
    connect unless @mpd.connected?
    async.run
  end

  def run
    @old_status = {}
    loop{listen}
  end

private
  def listen
    status = @mpd.status
    new_events = (status.to_a - @old_status.to_a).map(&:first)
    emit_changes(new_events)
    @old_status = status
    sleep 0.1
  end

  def emit_changes(events)
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
    begin
      $logger.info('MPD - Trying to connect')
      @mpd.connect
      $logger.info('MPD - Connected!')
    rescue Errno::ECONNREFUSED => error
      sleep 2
      retry
    end
  end
end