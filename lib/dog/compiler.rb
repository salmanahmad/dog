#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require 'stringio'

require File.join(File.dirname(__FILE__), 'compiler/compiler.rb')
require File.join(File.dirname(__FILE__), 'compiler/state.rb')

require File.join(File.dirname(__FILE__), 'compiler/rules/rule.rb')
Dir[File.join(File.dirname(__FILE__), "compiler/rules", "*.rb")].each { |file| require file }


module Dog end
