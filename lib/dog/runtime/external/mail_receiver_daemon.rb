require 'rubygems'
require 'daemons'
require 'json'

dir = File.dirname(__FILE__)
Daemons.run(dir + '/mail_receiver.rb')


