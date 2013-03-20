class MPDListener
  include Celluloid

  def initialize(mpd)
    @mpd = mpd
    @callbacks = {}
    connect unless @mpd.connected?
    async.run
  end

  def run
    @old_status = {}
    loop{listen}
  end

  def listen
    status = @mpd.status
    changed_keys = Hash[(status.to_a - @old_status.to_a)]
    trigger_callbacks(changed_keys)
    @old_status = status
    sleep 0.1
  end

  def trigger_callbacks(events)
    events.each do |event, value|
      perform(event, value) if @callbacks[event]
    end
  end

  def perform(event, value)
    @callbacks[event].each do |callback|
      callback.call(value)
    end
  end

  def on(event, &block)
    @callbacks[event] ||= []
    @callbacks[event].push block
  end

  def disengage!
    $logger.error('MPD - Cannot reconnect, aborting')
    exit 1
    # For some reason...
    terminate
    # =>
    # E, [2013-03-20T19:37:11.560795 #1152] ERROR -- : Supervisor crashed!
    # RuntimeError: a group member went missing. This shouldn't be!
  end

  def connect
    after(30) do
      disengage! unless @mpd.connected?
    end
    begin
      $logger.info('MPD - Trying to connect')
      @mpd.connect
    rescue Errno::ECONNREFUSED => error
      sleep 1
      retry
    end
  end
end