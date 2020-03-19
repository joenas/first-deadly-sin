# frozen_string_literal: true

require 'sinatra/reloader'
require 'dotenv/load'

class FirstSin < Sinatra::Base
  # Setup
  set :root, File.dirname(__FILE__)
  set :views, (proc { File.join(root, 'app/views') })
  set :public_folder, __dir__ + '/client/build'
  enable :logging
  # set :environment, :production

  configure :development do
    register Sinatra::Reloader
    also_reload './config/routes'
  end

  before '/*' do
    $mpd.connect unless $mpd.connected?
  end

  require './config/routes'
end
