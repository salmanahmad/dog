#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class Boolean; end
  
  class Structure
    
    FALSE_VALUES = [false, 0, '0', 'f', 'F', 'false', 'FALSE'].to_set

    TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE'].to_set
    
    BOOLEAN_VALUES = FALSE_VALUES | TRUE_VALUES
        
    def self.convert(value, type)
      return value if value.kind_of? type
      return nil if value.nil?
      
      if type.kind_of? Structure then
        if value.class != Hash then
          return nil
        else
          type.create_from_hash(value)
        end
      end
      
      if type.class == String then
        return value.to_s
      elsif type.class == Boolean then
        if BOOLEAN_VALUES.include?(value) then
          return TRUE_VALUES.include?(value)
        else
          return nil
        end
      elsif type.class == Numeric then
        return value.to_s.to_f
      else
        json = JSON.parse(value.to_s) rescue nil
        if json.kind_of? type then
          return json
        else
          return nil
        end
      end
    end
    
    def self.identifier
      self.name.downcase.gsub("::", ".")
    end
    
    def self.create_from_hash(params)
      object = self.new
      
      for name, options in self.properties do
        next if options[:direction] == "output"
        
        begin          
          object.send("#{name}=".intern, params[name])
          value = object.send(name.intern)
        rescue Exception => e
          @instances.delete object
          return nil
        end
      end
      
      return object
    end
    
    def self.instances(conditions = {})
      @instances ||= {}
      resultset = []
      
      
      for id, object in @instances do
        
        accept = true
        
        for property, value in conditions do
          accept = object[property] == value rescue false
          break unless accept
        end 
        
        resultset << object if accept
      end
      
      return resultset
    end
    
    def self.add_instance(object)
      @instances ||= {}
      @instances[object] = object
    end
    
    def initialize
      self.class.add_instance(self)
    end
    
    def save_to_hash()
      # TODO - This should check if all output stuff that is required
      # is written...
    end
    
    def self.properties
      @properties ||= {}
    end
    
    def [](property)
      self.send(property.intern)
    end
    
    def self.property(name, options = {})
      
      type = options[:type] || Object
      
      self.instance_eval do
        @properties ||= {}
        @properties[name] = options        
      end
      
      self.class_eval do
        define_method(name.intern) do
          instance_variable_get("@#{name}")
        end
        
        define_method("#{name}=".intern) do |arg|
          
          arg = self.class.convert(arg, type)
          
          if options[:required] && arg.nil? then
            raise "Error: Attempting to assign nil to required property #{name}."
          end
          
          if arg.kind_of?(type) || arg.kind_of?(NilClass)  then
            instance_variable_set("@#{name}", arg)
          else
            raise "Error: Attempting to assign property #{name} with invalid type (#{arg.class})."
          end
        end
      end
    end
    
  end
  
end