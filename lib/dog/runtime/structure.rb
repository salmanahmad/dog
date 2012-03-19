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

    def self.identifier
      self.name.downcase.gsub("::", ".")
    end
    
    def self.convert_value_to_type(value, type)
      return value if value.kind_of? type
      return nil if value.nil?
      
      if type.kind_of? Structure then
        return type.from_hash(value)
      elsif type.class == String then
        return value.to_s
      elsif type.class == Boolean then
        if BOOLEAN_VALUES.include?(value) then
          return TRUE_VALUES.include?(value)
        else
          return nil
        end
      elsif type.class == Numeric then
        return value.to_s.to_f
      elsif type.class == Object
        return value
      else
        return nil
      end
    end
    
    def self.from_hash(hash)
      object = self.new
      
      for name, options in self.properties do
        begin
          object[name] = hash[name]
        rescue Exception => e
          puts e
          return nil
        end
      end
      
      return object
    end
    
    def to_hash
      hash = {}      
      properties = self.class.properties
      
      for name, options in properties do
        if options.type.kind_of? Structure then
          hash[property] = self[property].to_hash
        else
          hash[property] = self[property]
        end
      end
      
      return hash
    end
    
    def [](property)
      self.send(property.intern)
    end
    
    def []=(property, value)
      self.send("#{property}=".intern, value)
    end
    
    def required_properties_present?
      for name, options in self.class.properties do
        if options[:required] && self[name].nil? then
          return false
        end
      end
      
      return true
    end
    
    def self.properties
      @properties ||= {}
      inherited_properties = superclass.properties rescue {}
      inherited_properties.merge @properties
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
          arg = self.class.convert_value_to_type(arg, type)
          
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