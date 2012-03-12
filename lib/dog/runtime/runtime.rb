#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  def self.bark! &block
    # TODO
    
    track = Track.new
    fiber = TrackFiber.new do
      yield
    end
    
    fiber.track = track
    fiber.resume
  end
  
  class Runtime
    
    def self.run(bark)
      runtime = self.new
      runtime.run(bark)
    end
    
    def initialize
      
    end
    
    def run(bark)
      EM.run do
        bark.run
        
        # TODO If there are no listeners that are active then 
        # (keep in mind, that ASKs may have implicit listeners):
        if Server.listeners? then
          port = Config.get('port')|| 4567
          
          Server.set :root, Environment.program_directory
          Thin::Server.start '0.0.0.0', port, Server
        else
          EM.stop
        end
      end
    end
    
  end
  
end