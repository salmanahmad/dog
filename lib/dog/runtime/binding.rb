#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class Binding
    
    def self.generate(data, context)
      klass = Class.new do
        
        for key, value in context do
          const_set(key.to_s, value)
        end
        
        def __get_binding__
          ::Kernel.binding
        end
        
        for key,value in data do
          define_method key do
            return value
          end
        end
        
      end
      
      klass.new.__get_binding__
    end
  end
  
end