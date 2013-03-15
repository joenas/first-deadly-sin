module MPDInfo
  def mpd_volume(method)
    $mpd.volume = $mpd.volume.send(method, 5)
  end

  def mpd_info
    $mpd.status.merge(current_song)
  end

  def current_song
    song = $mpd.current_song
    {
      :artist => song.artist,
      :album => song.album,
      :title => song.title,
      :file => song.file
    }
  end
end