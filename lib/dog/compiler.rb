#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require 'json'
require 'shellwords'
require 'digest/sha1'

require File.join(File.dirname(__FILE__), 'compiler/bundle.rb')
require File.join(File.dirname(__FILE__), 'compiler/compiler.rb')
require File.join(File.dirname(__FILE__), 'compiler/instructions.rb')
require File.join(File.dirname(__FILE__), 'compiler/native_package.rb')
require File.join(File.dirname(__FILE__), 'compiler/package.rb')

require File.join(File.dirname(__FILE__), 'compiler/rules/rule.rb')
Dir[File.join(File.dirname(__FILE__), "compiler/rules", "*.rb")].each { |file| require file }


module Dog end
