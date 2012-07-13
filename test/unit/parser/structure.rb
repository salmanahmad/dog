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
    @parser.parser.root = :structure
  end

  def test_single_line
    struct = <<-EOD
      { name = "name", string = "String" }
    EOD
    struct.strip!
    @parser.parse(struct)
    
    
    struct = <<-EOD
      { name = "name"       ,      string = "String" }
    EOD
    struct.strip!
    @parser.parse(struct)
    
  end

  def test_multi_line
    struct = <<-EOD
{
  name = "Name",
  
  ,,,,
  
  string = "string"
}
    EOD
    struct.strip!
    @parser.parse(struct)
    
    
    
    struct = <<-EOD
    {
      name = "Name",
      string = "string"
    }
    EOD
    struct.strip!
    @parser.parse(struct)
    

    struct = <<-EOD
    {
      name = "Name",,,
      string = "string"
    }
    EOD
    struct.strip!
    @parser.parse(struct)

    
    struct = <<-EOD
    {
      name = "Name"
      string = "string"
    }
    EOD
    struct.strip!
    @parser.parse(struct)
    
    
    struct = <<-EOD
    {
      
      name = "Name"
      
      
      string = "string"
    }
    EOD
    struct.strip!
    @parser.parse(struct)
    
    struct = <<-EOD
    {
      name = "Name"
  
  ,,   ,      
  
      string = "string"}
    EOD
    struct.strip!
    @parser.parse(struct)
    
    
    
    struct = <<-EOD
    {name = "Name"
  
  ,,   ,      
  
      string = "string"
    
      ,,, 
    }
    EOD
    struct.strip!
    pp @parser.parse(struct)
    
  end
  
end
