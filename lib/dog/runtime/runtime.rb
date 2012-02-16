#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class Runtime
    
    def self.run(bark)
      runtime = self.new
      runtime.run(bark)
    end
    
    def initialize
      
    end
    
    def run(bark)
      bark.run
    end
    
  end
  
end