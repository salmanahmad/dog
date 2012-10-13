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

  def test_find_by_id

    program = <<-EOD

    DEFINE car {
      name
    }

    DEFINE cars OF car

    civic = car { name = "civic" }
    SAVE civic TO cars

    id = COMPUTE dog.id ON civic
    new_civic = FIND id IN cars

    new_civic.name = "new_civic"

    EOD

    tracks = run_source(program)

    track = tracks.last

    civic = (track.variables["civic"])
    new_civic = (track.variables["new_civic"])

    assert_equal("civic", civic["name"].ruby_value)
    assert_equal("new_civic", new_civic["name"].ruby_value)
    assert_equal(civic._id, new_civic._id)
  end
  
  def test_find_by_id_2

    program = <<-EOD

    DEFINE car {
      name
    }

    DEFINE cars OF car

    civic = car { name = "civic" }
    SAVE civic TO cars

    new_civic = FIND civic IN cars

    new_civic.name = "new_civic"

    EOD

    tracks = run_source(program)

    track = tracks.last

    civic = (track.variables["civic"])
    new_civic = (track.variables["new_civic"])

    assert_equal("civic", civic["name"].ruby_value)
    assert_equal("new_civic", new_civic["name"].ruby_value)
    assert_equal(civic._id, new_civic._id)
  end

  def test_find
    program = <<-EOD

    DEFINE car {
      name
      index
    }

    DEFINE cars OF car

    civic = car {
      name = "civic"
    }

    civic.index = 0
    ADD civic TO cars
    
    civic.index = 1
    ADD civic TO cars
    
    civic.index = 2
    ADD civic TO cars
    
    civic.index = 3
    ADD civic TO cars
    
    civics = FIND cars WHERE name == "civic"
    first = civics[0]
    
    EOD
    
    
    tracks = run_source(program)
    
    assert_equal(4, tracks.last.variables["civics"].ruby_value.size)
    assert_equal("civic", tracks.last.variables["first"]["name"].ruby_value)
  end
  
  
  def test_remove
    program = <<-EOD

    DEFINE car {
      name
      index
    }

    DEFINE cars OF car

    civic = car {
      name = "civic"
    }

    civic.index = 0
    ADD civic TO cars
    
    civic.index = 1
    ADD civic TO cars
    
    civic.index = 2
    ADD civic TO cars
    
    civic.index = 3
    ADD civic TO cars
    
    civics = FIND cars WHERE name == "civic"
    PRINT COMPUTE collection.size ON civics
    
    REMOVE cars WHERE name == "civic"
    
    civics = FIND cars WHERE name == "civic"
    PRINT COMPUTE collection.size ON civics
    
    EOD

    tracks, output = run_source(program, true)
    assert_equal("4.0\n0.0", output)

  end


end
