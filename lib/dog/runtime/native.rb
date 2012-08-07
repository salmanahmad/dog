#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog  
  class NativeCode < ::Dog::Nodes::Node
    #attribute :name
    #attribute :package
    attr_accessor :name
    attr_accessor :package
    
    def initialize(name = nil, package = nil)
      self.name = name || self.class.name.split("::").last.downcase
      self.package = package
    end
    
    def read_definition
      # TODO - Is this done?
      value = ::Dog::Value.new("native_code", {
        "s:name" => ::Dog::Value.string_value(self.name.to_s)
      })
      
      return value
    end
    
    def visit(track)
      track.write_return_value(::Dog::Value.null_value)
      track.finish
    end
  end

  class NativeFunction < NativeCode

    def read_definition
      # TODO - Is this done?
      value = ::Dog::Value.new("native_function", {
        "s:name" => ::Dog::Value.string_value(self.name.to_s)
      })
      
      return value
    end

    def visit(track)
      args = nil
      optionals = {}
      
      if track.mandatory_arguments.kind_of? Array then
        args = []
        for v in track.mandatory_arguments do
          args << ::Dog::Value.from_hash(v)
        end
      else
        args = {}
        for k, v in track.mandatory_arguments do
          args[k] = ::Dog::Value.from_hash(v)
        end
      end
      
      for k, v in track.optional_arguments do
        optionals[k] = ::Dog::Value.from_hash(v)
      end
      
      return_value = self.run(args, optionals)
      return_value ||= ::Dog::Value.null_value
      
      track.write_return_value(return_value)
      track.finish
      return nil
    end
    
    def run(args = nil, optionals = nil)
      return ::Dog::Value.null_value
    end
    
  end
  
  class NativeStructure < NativeCode
    
    def read_definition
      # TODO - Is this done?
      value = ::Dog::Value.new("native_structure_definition", {
        "s:name" => ::Dog::Value.string_value(self.name.to_s)
      })
      
      return value
    end
    
    def visit(track)
      value = self.create
      track.write_return_value(value)
      track.finish
      return nil
    end
    
    def create
      return ::Dog::Value.empty_structure
    end
    
  end
end