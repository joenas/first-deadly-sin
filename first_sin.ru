$:.unshift File.join(File.dirname(__FILE__), '../lib')
require 'rubygems'
require 'bundler'
Bundler.require
require 'mpd_info'

require './first_sin'
run FirstSin

