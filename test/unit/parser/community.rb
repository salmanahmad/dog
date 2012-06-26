#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class ParserTests::CommunityTest < Test::Unit::TestCase

  def setup
    @parser = Dog::Parser.new
    @parser.parser.root = :community
  end

  def test_simple
    struct = <<-EOD
      DEFINE community twitter {
        name
        age
        gender
        relationship friends
        relationship followers, followees
        relationship student, teachers.teacher
      }
    EOD
    struct.strip!
    @parser.parse(struct)
  end
  
  def test_empty
    struct = <<-EOD
      DEFINE community foobar {
        
      }
    EOD
    struct.strip!
    @parser.parse(struct)
  end

end
