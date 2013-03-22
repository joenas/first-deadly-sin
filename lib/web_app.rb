module FirstSin
  class WebApp < Sinatra::Base
    # Setup
    set :root, Proc.new { File.join(File.dirname(__FILE__), '../') }
    set :views, Proc.new { File.join(root, "app/views") }
    enable :logging
    #set :environment, :production

    configure :development do
      register Sinatra::Reloader
      also_reload './config/routes'
    end

    before '/*' do
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
end