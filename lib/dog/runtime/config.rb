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
        
        database_default = Runtime.bundle.startup_package
        database_default = File.basename(Runtime.bundle_filename, ".bundle") if database_default == "" rescue ""
        
        @config ||= {
          'port' => 4242, 
          'dog_prefix' => '/dog',
          'database' => database_default
        }
        
        config_file ||= File.join(Runtime.bundle_directory, "config.json")
        
        @config.merge!(JSON.parse(File.open(config_file).read)) rescue nil
        @config.merge!(config)
        
        if @config["database"] == "" then
          raise "I could not start Dog because I did not have a database name I could use"
        end
        
        if @config["dog_prefix"][-1,1] == "/" then
          @config["dog_prefix"].chop!
        end
        
      end
      
      def reset
        @initialized = false
        @config = nil
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