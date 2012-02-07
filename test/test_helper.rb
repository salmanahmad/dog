#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require 'rubygems'
require 'test/unit'
require 'pp'

ENV['BUNDLE_GEMFILE'] = File.expand_path('../../Gemfile', __FILE__)

require 'rubygems'
require 'bundler/setup'
require File.expand_path('../../lib/dog.rb', __FILE__)

module IntegrationHelper
  
  def program_for(test_path)
    directory = File.absolute_path(File.dirname(File.basename(test_path)))
    basename = File.basename(test_path, ".rb") + ".dog"
    path = File.join(directory, basename)
    program = File.read(path)
    return program
  end
  
end

module UnitHelper
  
end