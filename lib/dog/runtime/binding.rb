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
    
    def self.generate(context)
      klass = Class.new do
        
        const_set('DormouseNewAccount', Environment.dormouse_new_account_url)
        const_set('DormouseNewSession', Environment.dormouse_new_session_url)
        
        for key, value in context do
          const_set(key.to_s, value)
        end
        
        # TODO - get rid of this cruft
        #def __get_binding__
        #  ::Kernel.binding
        #end
        
        #for key,value in data do
        #  define_method key do
        #    return value
        #  end
        #end
        
      end
      
      klass.new
    end
  end
  
end