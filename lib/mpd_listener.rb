class MPDListener
  include Celluloid

  def initialize(mpd)
    @mpd = mpd
    @callbacks = {}
  end

  def listen
    begin
      old_status = {}
      while true
        status = @mpd.status
        changed_keys = Hash[(status.to_a - old_status.to_a)].keys
        trigger_callbacks(changed_keys)
        old_status = status
        sleep 0.1
      end
    rescue Errno::ECONNRESET => error
      $logger.error(error.message)
    end
  end

  def trigger_callbacks(events)
    events.each {|event|
      if @callbacks[event]
        @callbacks[event].each {|callback|
          callback.call(event)
        }
      end
    }
  end

  def on(event, &block)
    @callbacks[event] ||= []
    @callbacks[event].push block
  end
end