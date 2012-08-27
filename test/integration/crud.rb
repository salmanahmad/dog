#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class IntegrationTests::CrudTest < Test::Unit::TestCase
  include RuntimeHelper

  def test_add
    program = <<-EOD

    DEFINE car {
      name
    }

    DEFINE cars OF car

    civic = car {
      name = "Salman"
    }

    ADD civic TO cars

    EOD

    tracks = run_source(program)

    cars = ::Dog.database["cars"]
    assert_equal(1, cars.count)

    car = cars.find_one
    assert_nothing_raised { car = ::Dog::Value.from_hash(car) }
    assert_equal("Salman", car["name"].ruby_value)
  end

  def test_add_multiple
    program = <<-EOD

    DEFINE car {
      name
    }

    DEFINE cars OF car

    civic = car {
      name = "Salman"
    }

    ADD civic TO cars
    ADD civic TO cars
    ADD civic TO cars

    EOD

    tracks = run_source(program)

    cars = ::Dog.database["cars"]
    assert_equal(3, cars.count)

    car = cars.find({})
    for c in car do
      assert_nothing_raised { c = ::Dog::Value.from_hash(c) }
      assert_equal("Salman", c["name"].ruby_value)
    end

  end
  

  def test_save
    program = <<-EOD

    DEFINE car {
      name
    }

    DEFINE cars OF car

    civic = car {
      name = "Accord"
    }

    SAVE civic TO cars
    
    civic.name = "Civic"
    SAVE civic TO cars
    
    EOD

    tracks = run_source(program)

    cars = ::Dog.database["cars"]
    assert_equal(1, cars.count)

    car = cars.find_one
    assert_nothing_raised { car = ::Dog::Value.from_hash(car) }
    assert_equal("Civic", car["name"].ruby_value)
  end
  
  
  
  def test_update
    program = <<-EOD

    DEFINE car {
      name
    }

    DEFINE cars OF car

    civic = car {
      name = "Accord"
    }

    UPDATE civic IN cars
    
    EOD

    tracks = run_source(program)

    cars = ::Dog.database["cars"]
    assert_equal(0, cars.count)
  end
  
  
  def test_delete
    program = <<-EOD

    DEFINE car {
      name
    }

    DEFINE cars OF car

    civic = car {
      name = "Accord"
    }

    SAVE civic TO cars
    
    civic.name = "Civic"
    SAVE civic TO cars
    DELETE civic FROM cars
    
    EOD

    tracks = run_source(program)

    cars = ::Dog.database["cars"]
    assert_equal(0, cars.count)
  end
  
  
  def test_find
    # TODO
  end
  
  
  def test_remove
    # TODO
  end


end
