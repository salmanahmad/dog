#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class ParserTests::PeopleTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
    @parser.parser.root = :user
  end
  
  def test_simple
    @parser.parse("PEOPLE FROM mit")
    @parser.parse("PERSON FROM mit")
    @parser.parse("PERSON FROM mit WHERE user.id == 7")
    @parser.parse("PERSON FROM mit WHERE id == 7 AND age < 25")
    @parser.parse("PEOPLE FROM communities['mit']")
  end
  
  def test_person
    @parser.parse("PERSON FROM lottery_entry")
  end
  
  def test_person_and_people
    @parser.parse("PEOPLE")
    @parser.parse("PERSON")
  end
  
  def test_from_optional
    @parser.parse("PEOPLE WHERE age > 7")
    @parser.parse("PERSON WHERE age > 7")
  end
  
  def test_assignment
    @parser.parser.root = :program
    @parser.parse("potential_matches = PEOPLE FROM learners WHERE learnables == interests.teachables OR teachables == interests.learables")
  end
  
end