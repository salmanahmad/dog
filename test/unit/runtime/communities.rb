#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class School < Dog::Community
  members_have do
    property "name"
  end
end

class RuntimeTests::CommunitiesTest < RuntimeTestCase
  
  def test_simple
    
  end
  
  
end