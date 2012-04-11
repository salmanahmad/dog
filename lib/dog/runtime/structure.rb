#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

# TODO - ObjectId as a type
# TODO - Default values for properties. This is useful for profile stuff as well when initializing the user's profile
# TODO - Repeated (boolean) option for repeated content instead of arrays
# TODO - Rethink Required properties. For example, with errors a required property may not be necessary

module Dog
    
  class Boolean; end
  
  module Properties
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      
      FALSE_VALUES = [false, 0, '0', 'f', 'F', 'false', 'FALSE'].to_set

      TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE'].to_set

      BOOLEAN_VALUES = FALSE_VALUES | TRUE_VALUES
      
      def identifier
        self.name.downcase.gsub("::", ".")
      end

      def convert_value_to_type(value, type)
        type = Kernel.qualified_const_get(type) if type.class == String
        
        return value if value.kind_of? type
        return nil if value.nil?

        if type.kind_of? Properties then
          return type.from_hash(value)
        elsif type == String then
          return value.to_s
        elsif type == Boolean then
          if BOOLEAN_VALUES.include?(value) then
            return TRUE_VALUES.include?(value)
          else
            return nil
          end
        elsif type == Numeric then
          return value.to_s.to_f
        elsif type == Object
          return value
        else
          return nil
        end
      end
      
      def import(params)
        object = self.from_hash(params)

        if object.required_input_present? then
          return object
        else
          return nil
        end
      end
      
      def from_hash(hash)
        object = self.new

        for name, options in self.properties do
          begin
            object[name] = hash[name]
          rescue Exception => e
            return nil
          end
        end

        return object
      end  
      
      def json_create(o)
        self.from_hash(o['data'])
      end
      
      def properties
        @properties ||= {}
        inherited_properties = superclass.properties rescue {}
        inherited_properties.merge @properties
      end

      def property(name, options = {})

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

            if type == Boolean && (arg.kind_of?(TrueClass) || arg.kind_of?(FalseClass) || arg.kind_of?(NilClass)) then
              instance_variable_set("@#{name}", arg)
            elsif arg.kind_of?(type) || arg.kind_of?(NilClass)  then
              instance_variable_set("@#{name}", arg)
            else
              raise "Error: Attempting to assign property #{name} with invalid type (#{arg.class})."
            end
          end
        end
      end
    end
    
    def initialize(params = {})
      for key, options in self.class.properties do
        if options[:value] then
          self[key] = options[:value]
        end
      end
      
      assign(params)
    end
    
    def export
      if self.required_output_present? then
        return self.to_hash
      else
        # TODO - Raise Exception Here!
        return nil
      end
    end
    
    def to_hash
      hash = {}      
      properties = self.class.properties
      
      for name, options in properties do
        if options[:type].kind_of? Properties then
          hash[name] = self[name].to_hash
        else
          hash[name] = self[name]
        end
      end
      
      return hash
    end
    
    def to_json
      {
        'json_class' => self.class.name,
        'data' => self.to_hash
      }.to_json
    end
    
    def assign(hash)
      # TODO - Error reporting
      for key, value in hash do
        self[key] = value
      end
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
    
    def required_input_present?
      for name, options in self.class.properties do
        next if options[:direction] == "output"
        
        is_directional_object = options[:type].kind_of?(Event) || options[:type].kind_of?(Task) || options[:type].kind_of?(Message)
        
        if is_directional_object then
          return nil unless object.required_input_present?
        elsif options[:type].kind_of? Record then
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
        
        is_directional_object = options[:type].kind_of?(Event) || options[:type].kind_of?(Task) || options[:type].kind_of?(Message)
        
        if is_directional_object then
          return nil unless object.required_output_present?
        elsif options[:type].kind_of? Record then
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
  
  class Structure
    include Properties
  end
  
end