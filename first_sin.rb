# frozen_string_literal: true

require 'sinatra/reloader'
require 'sinatra/asset_pipeline'

class FirstSin < Sinatra::Base
  # Setup
  set :root, File.dirname(__FILE__)
  set :views, (proc { File.join(root, 'app/views') })
  enable :logging
  # set :environment, :production

  # Assets
  set :assets_precompile, %w[app.js app.css *.png *.jpg *.svg *.eot *.ttf *.woff *.woff2]
  set :assets_paths, %w[app/assets]
  set :assets_css_compressor, :sass
  set :assets_js_compressor, :uglifier
  register Sinatra::AssetPipeline
  # set :precompiled_environments, %i[development production]

  configure :development do
    register Sinatra::Reloader
    also_reload './config/routes'
  end

  before '/*' do
    $mpd.connect unless $mpd.connected?
  end

  helpers do
    include Sprockets::Helpers
  end

  require './config/routes'
end
