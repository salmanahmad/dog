#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class ParserTests::StructureTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
    @parser.parser.root = :structure_definition
    #@parser.should_clean_tree = false
  end
  
  def test_event
    struct = <<-EOD
      event data {
        string name
        input string name
      }
    EOD
    struct.strip!
    @parser.parse(struct)
  end
  
  def test_relationship
    struct = <<-EOD
      record data {
        string name
        relationship friends
        relationship followers, followees
        relationship books, book.readers
      }
    EOD
    struct.strip!
    @parser.parse(struct)
  end
  
end