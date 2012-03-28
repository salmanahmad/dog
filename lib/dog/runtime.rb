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

require 'eventmachine'
require 'sequel'
require 'sequel/plugins/serialization'

require 'thin'
require 'sinatra/base'
require 'sinatra/async'
require 'uuid'
require 'json'

# TODO - It is kind of weird that I do load config, but nothing else. 
# Is that okay?
require File.join(File.dirname(__FILE__), 'runtime/config.rb')
require File.join(File.dirname(__FILE__), 'runtime/database.rb')

module Dog
  
  def self.bark!(run = true, &block)
    
    # I need to handle the fast startup logic here
    Database.initialize
    

    require File.join(File.dirname(__FILE__), 'runtime/structure.rb')
    require File.join(File.dirname(__FILE__), 'runtime/track.rb')
    require File.join(File.dirname(__FILE__), 'runtime/track_fiber.rb')
    require File.join(File.dirname(__FILE__), 'runtime/variable.rb')
    require File.join(File.dirname(__FILE__), 'runtime/server.rb')
    require File.join(File.dirname(__FILE__), 'runtime/record.rb')
    require File.join(File.dirname(__FILE__), 'runtime/person.rb')
    require File.join(File.dirname(__FILE__), 'runtime/event.rb')
    require File.join(File.dirname(__FILE__), 'runtime/message.rb')
    require File.join(File.dirname(__FILE__), 'runtime/task.rb')
    require File.join(File.dirname(__FILE__), 'runtime/commands.rb')
    
    require File.join(File.dirname(__FILE__), 'runtime/workflow.rb')
    require File.join(File.dirname(__FILE__), 'runtime/handler.rb')

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

      # TODO If there are no listeners that are active then 
      # (keep in mind, that ASKs may have implicit listeners):
      if Server.listeners? then
        Server.run if run
      else
        EM.stop
      end
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
