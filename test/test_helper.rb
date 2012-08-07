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
require 'rack/test'
require 'httparty'
require 'stringio'
require 'pp'

ENV['BUNDLE_GEMFILE'] = File.expand_path('../../Gemfile', __FILE__)

require 'rubygems'
require 'bundler/setup'
require File.expand_path('../../lib/dog.rb', __FILE__)

module ParserTests end
module CompilerTests end
module RuntimeTests end

module IntegrationHelper
  def program_for(test_path)
    directory = File.absolute_path(File.dirname(test_path))
    basename = File.basename(test_path, ".rb") + ".dog"
    path = File.join(directory, basename)
    program = File.read(path)
    return program
  end
end

module RuntimeHelper
  def invalid?(res)
    res.code < 100 || res.code >= 600;        
  end

  def informational?(res)
    res.code >= 100 && res.code < 200
  end
  
  def successful?(res)
    res.code >= 200 && res.code < 300
  end
  
  def redirection?(res)
    res.code >= 300 && res.code < 400
  end
  
  def client_error?(res)
    res.code >= 400 && res.code < 500
  end
  
  def server_error?(res)
    res.code >= 500 && res.code < 600
  end

  def ok?(res)
    res.code == 200
  end
  
  def bad_request?(res)
    res.code == 400
  end
  
  def forbidden?(res)
    res.code == 403
  end
  
  def not_found?(res)
    res.code == 404
  end
  
  def method_not_allowed?  res
    res.code == 405
  end
  
  def unprocessable?(res)
    res.code == 422
  end

  def redirect?(res)
    [301, 302, 303, 307].include? res.code
  end

end


class RuntimeTestCase < Test::Unit::TestCase
  def setup
    
  end
  
  def run_source(source, include_stdout = false)
    
  end
  
  def run_nodes(nodes, include_stdout = false)
    package = ::Dog::Package.new
    package.add_implementation
    
    nodes = [nodes] unless nodes.kind_of? Array
    
    for node in nodes do
      node.compile(package)
    end
    
    run_package(package, include_stdout)
  end
  
  def run_package(package, include_stdout = false)
    bundle = ::Dog::Bundle.new
    bundle.sign
    bundle.link(package)
    bundle.startup_package = package.name
    
    if include_stdout then
      sio = StringIO.new
      old_stdout, $stdout = $stdout, sio
    end
    
    tracks = ::Dog::Runtime.run(bundle, nil, {"config" => {"database" => "dog_unit_test"}, "database" => {"reset" => true}})    
    
    if include_stdout then
      $stdout = old_stdout
      stdout = sio.string.strip
    end
    
    
    if include_stdout then
      return tracks, stdout
    else
      return tracks
    end
  end
end

module UnitHelper
  
end