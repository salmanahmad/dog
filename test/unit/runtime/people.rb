#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class RuntimeTests::PeopleTest < RuntimeTestCase
  
  def test_main
    assert_equal(Dog::People.where("email" => "foo@foobar.com"), {"email" => "foo@foobar.com"})
    assert_equal(Dog::People.from("stanford").where("age" => 8), {"profile.stanford.age"=>8})
    assert_equal(Dog::People.from("stanford").where("age" => 8, "email" => "foo"), {"profile.stanford.age" => 8, "email" => "foo"})
  end
  
end