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
      
      def initialize(config_file = nil, config = {})
        return if @initialized
        @initialized = true
        
        @config ||= {
          'port' => 4242, 
          'dog_prefix' => '/dog',
          'database' => File.basename(Runtime.bite_code_filename, File.extname(Runtime.bite_code_filename))
        }
        
        config_file ||= File.join(File.dirname(Runtime.bite_code_filename), "config.json")
        
        @config.merge!(JSON.parse(File.open(config_file).read)) rescue nil
        @config.merge!(config)
        
        if @config["dog_prefix"][-1,1] == "/" then
          @config["dog_prefix"].chop!
        end
        
      end
      
      def reset
        @initialized = false
        @config = {}
      end
      
      def set(key, value)
        @config[key] = value
      end
      
      def get(key)
        @config[key]
      end
      
    end
    
  end
  
end