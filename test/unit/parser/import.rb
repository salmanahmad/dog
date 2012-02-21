#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

# TODO - Ensure that these parsed expression return the correct Tag

class ParserTests::ImportTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
    @parser.parser.root = :import
  end
  
  def test_function
    @parser.parse("IMPORT FUNCTION 'test'")
    @parser.parse("IMPORT FUNCTION 'test' AS test")
  end
  
  def test_data
    @parser.parse("IMPORT DATA 'data'")
    @parser.parse("IMPORT DATA 'data' AS data")
  end
  
  def test_community
    @parser.parse("IMPORT COMMUNITY 'community'")
    @parser.parse("IMPORT COMMUNITY 'community' AS community")
  end
  
  def test_task
    @parser.parse("IMPORT TASK 'task'")
    pp @parser.parse("IMPORT TASK 'task' AS task")
  end
  
  def test_message
    @parser.parse("IMPORT MESSAGE 'message'")
    @parser.parse("IMPORT MESSAGE 'message' AS message")
  end
  
  def test_config
    @parser.parse("IMPORT CONFIG 'config'")
    @parser.parse("IMPORT CONFIG 'config' AS config")
  end
  
end