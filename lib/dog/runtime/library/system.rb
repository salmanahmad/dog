#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog::Library
  module System
    include ::Dog::NativePackage
    
    name "system"
    
    implementation "print" do
      argument "arg"
      
      body do |track|
        puts variable("arg").ruby_value
      end
    end
    
    implementation "person_from_value" do
      argument "value"
      
      body do
        value = variable("value")
        person = value.person
        
        if person.nil? then
          person = ::Dog::Value.null_value
        end
        
        dog_return(person)
      end
    end
    
    implementation "type_of" do
      argument "value"
      
      body do
        value = variable("value")
        type = value.type
        dog_return ::Dog::Value.string_value(type)
      end
    end
  end
end