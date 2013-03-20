class MPDListener
  include Celluloid

  def initialize(mpd)
    @mpd = mpd
    @callbacks = {}
  end

  def run
    begin
      @old_status = {}
      loop{listen}
    rescue Errno::ECONNRESET => error
      $logger.error("MPD - #{error.message}")
    end
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
end