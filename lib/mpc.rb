require 'singleton'
class MPC
  include Singleton
  attr_reader :mpd
  attr_accessor :host, :port

  def initialize
  end

  def setup(host, port, volume_change = 5)
    @host = host
    @port = port
    @mpd = nil
    @volume_change = volume_change
    self
  end

  def controller
    @mpd
  end

  def vol(method)
    @mpd.do 'setvol', self.info[:volume].send(method, @volume_change)
  end

  def connect
    #return "OK" if self.active?
    unless self.active?
      begin
        @mpd = MPD::Controller.new @host, @port
      rescue Exception => error
        @mpd = nil
        return error.message
      end
    end
    return "OK"
  end

  def active?
    return false unless @mpd
    @mpd.active?
  end

  def playlist
    return {:error => 'no MPD connection'} unless self.active?
    @mpd.playlist
  end

  def info
    return {:error => 'no MPD connection'} unless self.active?
    @mpd.info
  end

  def do(args)
    return false unless self.active?
    @mpd.do *args
  end
end