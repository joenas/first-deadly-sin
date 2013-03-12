class FirstSin < Sinatra::Base
  # Setup
  set :root, File.dirname(__FILE__)
  set :views, Proc.new { File.join(root, "app/views") }
  set :_mpd_host, 'localhost'
  set :_mpd_port, 6600
  enable :logging

  FAYE_SERVER_URL = 'http://localhost:9292/faye'
  include FayeBroadcast

  configure :development do
    register Sinatra::Reloader
    also_reload './config/routes'
  end

  configure do
    $mpd = MPC.instance.setup(_mpd_host, _mpd_port)
  end

  before '/mpd*' do
    status = $mpd.connect
    logger.info "######## MPD ########: #{status}"
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
