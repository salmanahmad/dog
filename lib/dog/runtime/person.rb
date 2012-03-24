#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  class Person
    # TODO
    
    def self.new
      # TODO - This is the hack of all hacks but kinda cool.
      # Decide if you want to keep it or you want to change
      # to something else...
      @class ||= Class.new(Sequel::Model(:users)) do
        
      end
      @class.new
    end
    
  end

  class People
    # TODO
    
    def self.from
      
    end
    
    def self.where
      
    end
    
  end
end