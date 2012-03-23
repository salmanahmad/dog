#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  at_exit do
    puts
    puts "Dog is going to sleep. Bai!"
  end
  
  def self.bark!(run = true, &block)
    EM.run do
      track = Track.new
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