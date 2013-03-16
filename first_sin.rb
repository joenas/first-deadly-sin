require 'rubygems'
require 'bundler'
Bundler.require
Dir[File.dirname(__FILE__) + '/lib/*'].each {|file| require file }

class FirstSin < Sinatra::Base
  # Setup
  set :root, File.dirname(__FILE__)
  set :views, Proc.new { File.join(root, "app/views") }
  set :images, Proc.new { File.join(root, "app/images/artists") }
  set :mpd_host, '10.0.0.12'
  set :mpd_port, 6600
  enable :logging

  include MPDInfo

  configure :development do
    register Sinatra::Reloader
    also_reload './config/routes'
  end

  configure do
    $redis = Redis.new
    $mpd = MPD.new mpd_host, mpd_port
    $mpd.connect
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
