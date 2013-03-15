$stdout.sync = true

class FirstSin < Sinatra::Base
  include MPDInfo

  # Setup
  set :root, File.dirname(__FILE__)
  set :views, Proc.new { File.join(root, "app/views") }
  set :_mpd_host, '10.0.0.12'
  set :_mpd_port, 6600
  enable :logging

  configure :development do
    register Sinatra::Reloader
    also_reload './config/routes'
  end

  configure do
    $mpd = MPD.new _mpd_host, _mpd_port
    $mpd.connect
  end

  # assets
  register Sinatra::AssetPack

  assets {
    prebuild true
    serve '/img', from: 'app/images'    # Optional
    js_compression  :yui, :munge => true
    js :vendor, [
      '/js/vendor/jquery.js',
      '/js/vendor/underscore.js',
      '/js/vendor/*.js'
    ]
    js :app, [ '/js/app/*.js' ]
    css :app, [ '/css/font-awesome.min.css', '/css/application.css', '/css/responsive.css' ]
  }

  require './config/routes'
end
