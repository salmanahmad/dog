#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

# TODO - Figure this out. CollarNodes depends on State. I may want to
# just remove my directory structure to make this a bit more straight
# forward.

require File.join(File.dirname(__FILE__), 'dog/version.rb')
require File.join(File.dirname(__FILE__), 'dog/compiler.rb')
require File.join(File.dirname(__FILE__), 'dog/parser.rb')
require File.join(File.dirname(__FILE__), 'dog/runtime.rb')

module Dog end