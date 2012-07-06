#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#


require 'digest/sha1'

require 'thin'
require 'eventmachine'
require 'sinatra/base'
require 'sinatra/async'
require 'uuid'
require 'json'
require 'mongo'

# TODO Add back the Instant Messaging Capabilities.
#require 'blather/client/client'

require File.join(File.dirname(__FILE__), 'runtime/database_object.rb')
require File.join(File.dirname(__FILE__), 'runtime/routability.rb')

require File.join(File.dirname(__FILE__), 'runtime/community.rb')
require File.join(File.dirname(__FILE__), 'runtime/config.rb')
require File.join(File.dirname(__FILE__), 'runtime/database.rb')
require File.join(File.dirname(__FILE__), 'runtime/handler.rb')
require File.join(File.dirname(__FILE__), 'runtime/kernel_ext.rb')
require File.join(File.dirname(__FILE__), 'runtime/message.rb')
require File.join(File.dirname(__FILE__), 'runtime/person.rb')
require File.join(File.dirname(__FILE__), 'runtime/property.rb')
require File.join(File.dirname(__FILE__), 'runtime/server.rb')
require File.join(File.dirname(__FILE__), 'runtime/task.rb')
require File.join(File.dirname(__FILE__), 'runtime/track.rb')
require File.join(File.dirname(__FILE__), 'runtime/variable.rb')
require File.join(File.dirname(__FILE__), 'runtime/vet.rb')

module Dog
  
  class Runtime
    class << self
      attr_accessor :bite_code
      attr_accessor :bite_code_filename
      
      def run_file(bite_code_filename, options = {})
        self.run(File.open(bite_code_filename).read, bite_code_filename, options)
      end
      
      def run(bite_code, bite_code_filename, options = {})
        
        options = {
          "config_file" => nil,
          "config" => {},
          "database" => {}
        }.merge!(options)
        
        bite_code = JSON.load(bite_code)
        
        if bite_code["version"] != VERSION::STRING then
          raise "This program was compiled using a different version of Dog. It was compiled with #{bite_code["version"]}. I am Dog version #{VERSION::STRING}."
        end
        
        code = {}
        for filename, ast in bite_code["code"]
          code[filename] = Nodes::Node.from_hash(ast)
        end
        
        bite_code["code"] = code
        
        self.bite_code = bite_code
        self.bite_code_filename = bite_code_filename
        
        Config.initialize(options["config_file"], options["config"])
        Database.initialize(options["database"])
        Track.initialize_root("root", bite_code["main_filename"])
        Server.run
      end
      
      def node_at_path_for_filename(path, file)
        node = self.bite_code["code"][file]
        
        for index in path do
          node = node.elements[index]
        end
        
        return node
      end
      
    end
  end
  
end
