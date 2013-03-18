class FirstSin < Sinatra::Base
  # Setup
  set :root, File.dirname(__FILE__)
  set :views, Proc.new { File.join(root, "app/views") }
  set :mpd_host, ENV['MPD_HOST'] || 'localhost'
  set :mpd_port, ENV['MPD_PORT'] || 6600
  enable :logging

  configure :development do
    register Sinatra::Reloader
    also_reload './config/routes'
  end

  configure do
    $mpd = MPD.new mpd_host, mpd_port
  end

  before "/*" do
    $mpd.connect unless $mpd.connected?
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
