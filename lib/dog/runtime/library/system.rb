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
    
    implementation "print:on" do
      argument "arg"
      
      body do |track|
        puts variable("arg").ruby_value
      end
    end
    
    implementation "inspect:on" do
      argument "arg"
      
      body do |track|
        puts variable("arg").ruby_value.inspect
      end
    end
    
    
    implementation "keys" do
      argument "value"
      
      body do
        value = variable("value")
        keys = ::Dog::Value.empty_array
        
        value = variable("value")
        value_keys = value.keys
        value_keys.each_index do |index|
          key = value_keys[index]
          if key.kind_of?(String) then
            keys[index] = ::Dog::Value.string_value(key)
          elsif key.kind_of?(Numeric)
            keys[index] = ::Dog::Value.number_value(key)
          else
            raise "Invalid struture key"
          end
        end
        
        dog_return(keys)
      end
    end
    
    implementation "size:on" do
      argument "value"
      
      body do
        value = variable("value")
        size = value.value.keys.size
        
        dog_return(::Dog::Value.number_value(size))
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
    
    implementation "type:of" do
      argument "value"
      
      body do
        value = variable("value")
        type = value.type
        dog_return ::Dog::Value.string_value(type)
      end
    end
  end
end