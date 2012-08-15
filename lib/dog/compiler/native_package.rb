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
      
      class Helper
        attr_accessor :track
        
        def initialize(track)
          @track = track
        end
        
        def variable(name)
          track.variables[name]
        end
        
        def dog_return(value)
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
      
      def structure(symbol, &block)
        s = Structure.new
        s.instance_eval(&block)
        
        value = ::Dog::Value.new("type", {})
        value["name"] = ::Dog::Value.string_value(symbol)
        value["package"] = ::Dog::Value.string_value(self.package.name)
        
        instructions = Proc.new do
          # TODO - Build and return the structure
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
        
        value = ::Dog::Value.new("function", {})
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
          end
          
          track.finish
        end
        
        self.package.pop_symbol
      end
    end
  end
end