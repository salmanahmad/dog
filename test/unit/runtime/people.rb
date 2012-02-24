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
  
  def test_simple
    output = run_code("PEOPLE FROM mit WHERE id == 7", :user)
    assert_equal(output, {"people" => {"from" => "mit", "where" => 
      [["id"], "==", 7]
    }})
  end
  
  def test_binary_condition
    output = run_code("PEOPLE FROM mit WHERE id == 7 AND interests CONTAINS 'fencing'", :user)
    assert_equal(output, {"people" => {"from" => "mit", "where" => 
      [[["id"], "==", 7], "AND", [["interests"], "CONTAINS", 'fencing']]
    }})
  end
  
  def test_unary_condition
    output = run_code("PEOPLE FROM mit WHERE id == 7 AND NOT(interests CONTAINS 'fencing')", :user)
    assert_equal(output, {"people" => {"from" => "mit", "where" => 
      [[["id"], "==", 7], "AND", ['NOT', [["interests"], "CONTAINS", 'fencing']]]
    }})
  end
  
end