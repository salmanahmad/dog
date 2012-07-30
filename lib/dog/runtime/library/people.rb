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
        value = ::Dog::Value.new("person", {})
        value._id = UUID.new.generate
        value.value = {
          "s:id" => ::Dog::Value.string_value(value._id),
          "s:first_name" => ::Dog::Value.null_value,
          "s:last_name" => ::Dog::Value.null_value,
          "s:handle" => ::Dog::Value.null_value,
          "s:email" => ::Dog::Value.null_value,
          "s:facebook" => ::Dog::Value.null_value,
          "s:twitter" => ::Dog::Value.null_value,
          "s:google" => ::Dog::Value.null_value,
          "s:communities" => ::Dog::Value.null_value,
          "s:profile" => ::Dog::Value.null_value
        }
        
        return value
      end
    end
    
  end
end
