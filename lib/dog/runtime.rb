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

require 'blather/client/client'

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
  
  def self.bark!(run = true, &block)
    
    # I need to handle the fast startup logic here
    Database.initialize
    
    EM.run do
      track = Track.root
      fiber = TrackFiber.new do
        yield if block
      end
      
      fiber.track = track
      fiber.resume
      
      # TODO - This is here for testing
      Server.global_track = track
      Server.boot
      
      # TODO - Are there times where you don't want to run the server?
      Server.run if run
      
    end

    # TODO - This is here for testing
    return Server
  end

  class Runtime

    def self.run(bark)
      runtime = self.new
      runtime.run(bark)
    end

    def run(bark)
      eval(bark)
    end

  end

end
