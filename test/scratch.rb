#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

# Note: This file is not an official part of the Dog source tree.
# It is intended for the developer to try stuff out in between
# commits. Because he is an idiot, he checked it in, and realized
# he kinda liked it so left it in. 
#
# Yes, he is kinda strange...

require File.join(File.dirname(__FILE__), 'test_helper.rb')

class ScratchTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
    @parser.parser.root = :predicate
  end
  
  def test_assignment
    @parser.parse("i == 5")

  end
  
end