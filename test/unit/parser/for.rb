#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class ParserTests::ForTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
    @parser.parser.root = :for
  end

  def test_empty_for
    program = <<-EOD
    FOR EACH a IN b DO 

    END
    EOD

    @parser.parse(program.strip)
  end

  def test_statements
    program = <<-EOD
FOR EACH a IN b DO
  a = a + 1
END
    EOD

    @parser.parse(program.strip)

  end

  def test_indent
    program = <<-EOD
    FOR EACH a IN b DO
      a = a + 1
    END
    EOD
    # TODO -- IN CLAUSE IS NOT COMPILING TO ANYTHING AT THE MOMENT!!!
    @parser.parse(program.strip)

  end

  def test_until
    # TODO - Bring this back maybe?
    #program = <<-EOD
    #FOR EACH a IN b DO
    #  c = a + 1
    #UNTIL c == 7
    #EOD
    #
    #@parser.parse(program.strip)
    #
    #program = <<-EOD
    #FOR EACH a IN b DO
    #  c = a + 1
    #UNTIL c + 7 - 9
    #EOD
    #
    #@parser.parse(program.strip)

  end


  
  
end