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
    @old_status = {}
    loop{listen}
  end

private
  def listen
    status = @mpd.status
    emit_events status.diff(@old_status).keys
    @old_status = status
    sleep 0.2
  end

  def emit_events(events)
    @publisher.mailbox << (events & @monitored_events)
  end

  def disengage!
    FirstSin.logger.error('MPD - Cannot reconnect, aborting')
    Celluloid.shutdown and exit 1
  end

  def connect
    after(30) do
      disengage! unless @mpd.connected?
    end
    FirstSin.logger.info('MPD - Trying to connect')
    @mpd.connect
    FirstSin.logger.info('MPD - Connected!')
  rescue Errno::ECONNREFUSED => error
    sleep 2
    retry
  end
end