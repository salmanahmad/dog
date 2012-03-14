#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class Config
    
    class << self
      
      def reset
        @config = {}
      end
      
      def set(key, value)
        @config ||= {'port' => 4567, 'dog_prefix' => '/dog/' }
        @config[key] = value
      end
      
      def get(key)
        @config ||= {'port' => 4567, 'dog_prefix' => '/dog/' }
        @config[key]
      end
      
    end
    
  end
  
end