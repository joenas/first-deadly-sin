require 'rubygems'
require 'bundler'
Bundler.require
Dir[File.dirname(__FILE__) + '/lib/*'].each {|file| require file }
require './first_sin'
run FirstSin

