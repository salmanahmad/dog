#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class Event < Structure
    property "success", :type => Boolean, :direction => "output"
    property "errors", :type => Array, :direction => "output"
    
    def self.import(params)
      object = self.from_hash(params)
      
      if object.required_input_present? then
        return object
      else
        return nil
      end
    end
    
    def export
      if self.required_output_present? then
        return self.to_hash
      else
        return nil
      end
    end
    
    def required_input_present?
      
      for name, options in self.class.properties do
        next if options[:direction] == "output"
        
        if options[:type].kind_of? Event then
          return nil unless object.required_input_present?
        elsif options[:type].kind_of? Structure then
          return nil unless object.required_properties_present?
        else
          if options[:required] && options[:direction] == "input" && self[name].nil? then
            return false
          end
        end
        
      end
      
      return true
    end
    
    def required_output_present?
      
      for name, options in self.class.properties do
        next if options[:direction] == "input"
        
        if options[:type].kind_of? Event then
          return nil unless object.required_output_present?
        elsif options[:type].kind_of? Structure then
          return nil unless object.required_properties_present?
        else
          if options[:required] && options[:direction] == "output" && self[name].nil? then
            return false
          end
        end
      end
      
      return true
    end
    
  end
  
  class SystemEvent < Event
    def self.identifier
      self.name.downcase.split("::")[1..-1].join(".")
    end
  end
  
  class Account < SystemEvent

    class SignIn < SystemEvent
      
    end
    
    class SignOut < SystemEvent
      
    end
    
    class Create < SystemEvent
      property "email", :type => String, :required => true, :direction => "input"
      property "password", :type => String, :direction => "input"
      property "confirm", :type => String, :direction => "input"
    end
    
  end
  
  class Community < SystemEvent

    class Join < SystemEvent
      
    end
    
    class Leave < SystemEvent
      
    end
    
  end
  
  
end