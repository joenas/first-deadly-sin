
module MPD
  class Controller
    def current_song
      song = {}
      fields = self.do :currentsong
      fields.each do |name, value|
        song[name.downcase] = value
      end
      song
    end

    def info
      info = current_song
      exclude = [:mixrampdb, :mixrampdelay, :consume, :xfade ]
      fields = self.do :status
      fields.each do |name, value|
        info[name.downcase] = value unless exclude.include? name
      end
      info
    end

  end
end