class MPD
  module Plugins
    module Information
      def info
        song = current_song
        status.merge(
          {
            :artist => song.artist,
            :album => song.album,
            :title => song.title,
            :file => song.file
          }
        )
      end
    end

    module PlaybackOptions
      def volup(change)
        new_vol = (volume + change)
        self.volume = (new_vol >= 100) ? 100 : new_vol
      end

      def voldown(change)
        new_vol = (volume - change)
        self.volume = (new_vol <= 0) ? 0 : new_vol
      end
    end
  end
end