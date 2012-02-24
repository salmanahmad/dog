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

class RuntimeTestCase < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
    @compiler = Dog::Compiler.new
    @runtime = Dog::Runtime.new
  end
  
  def run_code(code, root = :program)
    Dog::Environment.reset
    
    sio = StringIO.new
    old_stdout, $stdout = $stdout, sio
    
    @parser.parser.root = root
    collar = @parser.parse(code)
    bark = @compiler.compile(collar)
    output_value = bark.run
    
    $stdout = old_stdout
    output_stdout = sio.string.strip
    
    if root == :program then
      output_stdout
    else
      output_value
    end
  end
  
end

module UnitHelper
  
end