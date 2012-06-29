#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#


require 'fiber'
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
require File.join(File.dirname(__FILE__), 'runtime/structure.rb')

require File.join(File.dirname(__FILE__), 'runtime/collection.rb')
require File.join(File.dirname(__FILE__), 'runtime/commands.rb')
require File.join(File.dirname(__FILE__), 'runtime/community.rb')
require File.join(File.dirname(__FILE__), 'runtime/config.rb')
require File.join(File.dirname(__FILE__), 'runtime/database.rb')
require File.join(File.dirname(__FILE__), 'runtime/event.rb')
require File.join(File.dirname(__FILE__), 'runtime/handler.rb')
require File.join(File.dirname(__FILE__), 'runtime/kernel_ext.rb')
require File.join(File.dirname(__FILE__), 'runtime/message.rb')
require File.join(File.dirname(__FILE__), 'runtime/person.rb')
require File.join(File.dirname(__FILE__), 'runtime/record.rb')
require File.join(File.dirname(__FILE__), 'runtime/server.rb')
require File.join(File.dirname(__FILE__), 'runtime/task.rb')
require File.join(File.dirname(__FILE__), 'runtime/track.rb')
require File.join(File.dirname(__FILE__), 'runtime/track_fiber.rb')
require File.join(File.dirname(__FILE__), 'runtime/variable.rb')
require File.join(File.dirname(__FILE__), 'runtime/workflow.rb')

module Dog
  
  class Runtime
    class << self
      attr_accessor :bite_code
      attr_accessor :bite_code_filename
      
      def run_file(bite_code_filename, options = {})
        self.run(File.open(bite_code_filename).read, bite_code_filename, options)
      end
      
      def run(bite_code, bite_code_filename, options = {})
        # TODO - Parse the bite code initially.
        self.bite_code = bite_code
        self.bite_code_filename = bite_code_filename
        
        Config.initialize(options["config_file"], options["config"])
        Database.initialize
        Track.initialize_root([bite_code["main_filename"], 0])
        Server.initialize
        
        Server.run
      end
    end
  end
  
end
