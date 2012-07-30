#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog::Library
  module People
    
    def self.name
      "people"
    end
    
    def self.symbols
      return {
        "person" => Person.new
      }
    end
    
    class Person < ::Dog::NativeStructure
      def read_definition
        # TODO - Again, I probably really want to add something more sophisticated here
        super
      end
      
      def create
        
      end
    end
    
  end
end
