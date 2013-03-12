module Configuration
  def mpd_port(port)
    set :_mpd_port, port
  end

  def mpd_host(host)
    set :_mpd_host, host
  end

  def configuration(file)
    eval File.open(file).read
  end
end