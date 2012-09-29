#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#


module Dog
  
  # TODO - Change this to a class-based API instead of a DSL API
  
  class NativeImplementation
    class << self
      attr_accessor :arguments
    end
    
    def self.argument(argument, options = {})
      self.arguments << argument
    end
    
    def execute
      raise "Must be overridden"
    end
  end
  
  class NativeStructure
    class << self
      attr_accessor :properties
    end
    
    def self.property(property, options = {})
      self.properties << property
    end
    
    def execute
      
    end
  end
  
  class NativeValue
    def value
      
    end
  end
  
  module NativePackage
    
    def self.included(c)
      c.extend ClassMethods
    end
        
    module ClassMethods
      class Implementation
        attr_accessor :arguments
        attr_accessor :optional_arguments
        attr_accessor :instructions

        def initialize
          self.arguments = []
          self.optional_arguments = []
        end

        def argument(arg, options = {})
          self.arguments << arg.to_s
        end

        def optional(arg, options = {})
          self.optional_arguments << arg.to_s
        end

        def body(&block)
          self.instructions = block
        end
      end
      
      class Structure
        attr_accessor :properties
        
        def initialize
          self.properties = []
        end
        
        def property(name, options = {})
          options["name"] = name
          self.properties << options
        end
      end
      
      
      class Collection
        attr_accessor :type_package
        attr_accessor :type_name
        
        def initialize
          self.type_package = ""
          self.type_name = ""
        end
        
        def type(name)
          name = name.split(".")
          
          if name.size == 2 then
            self.type_package = name[0]
            self.type_name = name[1]
          else
            self.type_name = name[0]
          end
        end
      end
      
      class Helper
        attr_accessor :track
        
        def initialize(track)
          @track = track
        end
        
        def variable(name)
          track.variables[name]
        end
        
        def dog_return(value = ::Dog::Value.null_value)
          # TODO - Handle multiple returns
          if value.kind_of? ::Dog::Value then
            track.stack.push(value)
          else
            track.stack.push(::Dog::Value.from_ruby_value(value))
          end
          
          throw :return
        end
      end
      
      def package
        @package ||= Package.new
      end
      
      def name(name)
        self.package.name = name
      end
      
      def value(symbol, &block)
        value = block.call
        
        self.package.push_symbol(symbol)
        self.package.current_context["value"] = value
        self.package.pop_symbol
      end
      
      def collection(symbol, &block)
        c = Collection.new
        c.instance_eval(&block)
        
        value = ::Dog::Value.new("dog.collection", {})
        value["name"] = ::Dog::Value.string_value(symbol)
        value["package"] = ::Dog::Value.string_value(self.package.name)
        
        instructions = Proc.new do |track|
          type = ::Dog::Value.new("dog.type", {})
          type["name"] = ::Dog::Value.string_value(c.type_name)
          type["package"] = ::Dog::Value.string_value(c.type_package)
          
          track.stack.push(type)
          track.finish
        end
        
        self.package.push_symbol(symbol)
        self.package.current_context["value"] = value
        self.package.add_implementation
        self.package.implementation["instructions"] = instructions
        self.package.pop_symbol
      end
      
      def structure(symbol, &block)
        s = Structure.new
        s.instance_eval(&block)
        
        value = ::Dog::Value.new("dog.type", {})
        value["name"] = ::Dog::Value.string_value(symbol)
        value["package"] = ::Dog::Value.string_value(self.package.name)
        
        instructions = Proc.new do |track|
          struct = ::Dog::Value.new("#{self.package.name}.#{symbol}", {})
          for property in s.properties do
            property_name = property["name"]
            struct[property_name] = ::Dog::Value.null_value
          end
          
          track.stack.push(struct)
          track.finish
        end
        
        self.package.push_symbol(symbol)
        
        self.package.current_context["value"] = value
        
        self.package.add_implementation
        self.package.implementation["instructions"] = instructions
        
        self.package.pop_symbol
      end
      
      def implementation(symbol, &block)
        i = Implementation.new
        i.instance_eval(&block)
        
        value = ::Dog::Value.new("dog.function", {})
        value["name"] = ::Dog::Value.string_value(symbol)
        value["package"] = ::Dog::Value.string_value(self.package.name)
        
        self.package.push_symbol(symbol)
        
        self.package.current_context["value"] = value
        
        self.package.add_implementation
        self.package.implementation["arguments"] = i.arguments
        self.package.implementation["optional_arguments"] = i.optional_arguments
        self.package.implementation["instructions"] = Proc.new do |track|
          catch :return do
            Helper.new(track).instance_exec(track, &i.instructions)
            track.stack.push(::Dog::Value.null_value)
          end
          track.finish
        end
        
        self.package.pop_symbol
      end
    end
  end
end