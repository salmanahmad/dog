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
    
    implementation "type" do
      argument "value"
      
      body do
        value = args.first.type
        return ::Dog::Value.string_value(value)
      end
    end
  end
end