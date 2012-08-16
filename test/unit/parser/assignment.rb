#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class ParserTests::AssignmentTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
    @parser.parser.root = :assignment
  end
  
  def test_assignment
    
    @parser.parse("i = ASK ME VIA email TO rank")
    @parser.parse("i = j = k = 5")
    @parser.parse("i = 0")
    @parser.parse("i = 1")
    @parser.parse("i = -1")
    @parser.parse("i = 1.1")
    @parser.parse("i = -1.1")
    @parser.parse("i = true")
    @parser.parse("i = false")
    @parser.parse('i = "Foo bar"')
    @parser.parse("i = 'Foo bar'")
    @parser.parse("i = {'key'='value'}")

    @parser.parse("i.j = 8") 
    @parser.parse("i[i] = {'key'='value'}")
    @parser.parse("i[0] = {'key'='value'}")
    @parser.parse("i['string'] = {'key'='value'}")
    @parser.parse("i[j[k]][l] = {'key'='value'}")

    @parser.parse("i.j.k.l = {'key'='value'}")
    
    # TODO - Add back possessives
    #@parser.parse("i's j's k = {'key':'value'}")
  end
end
