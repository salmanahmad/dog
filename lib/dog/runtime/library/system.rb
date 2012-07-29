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
    
    def self.name
      "system"
    end
    
    def self.symbols
      [
        ["add", "add"],
        ["type", "type"]
      ]
    end
    
    def self.type(args = nil, optionals = nil)
      value = args.first.type
      return ::Dog::Value.string_value(value)
    end
    
    def self.add(args = nil, optionals = nil)
      
      value = 0
      
      for arg in args do
        value += arg.ruby_value
      end
      
      return ::Dog::Value::number_value(value)
    end
  end
end