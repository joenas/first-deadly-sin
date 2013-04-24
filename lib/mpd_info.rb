class MPD
  module Plugins
    module Information
      def info
        song = current_song
        if song
          status.merge(
          {
            :artist => song.artist,
            :album => song.album,
            :title => song.title,
            :file => song.file
          })
        else
          status
        end
      end
    end

    module PlaybackOptions
      def volup(change)
        self.volume = [100, (volume+change)].min
      end

      def voldown(change)
        self.volume = [0, (volume-change)].max
      end
    end
  end
end