#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class ParserTests::CommentTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
  end
  
  def test_simple
    @parser.parse("  \t  # comments")
    @parser.parse("# comments")
    @parser.parse("1+2 # comments")
    @parser.parse("1+2 # comments\n\n\n")
    @parser.parse("\n\n\n  1+2 # comments\n\n\n")
  end
  
  def test_comment_with_string
    @parser.parse(%Q|# comments "This is a string"\n|)
    @parser.parse("\n\n\n  1+2 # comments \"This is a string\" \n\n\n")
  end
  
  def test_hash
    program = <<-EOD
    
    #comment
    
    i = { 
      'key'='value' #comment
    }
    i
    EOD
    
    @parser.parse(program)
  end
  
  def test_function
    program = <<-EOD
DEFINE function ON input DO # comments
  # comments
END
    EOD
    
    @parser.parse(program)
    @parser.parse(program.strip)
    
  end
  
end