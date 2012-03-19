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
    EM.run do
      track = Track.new
      fiber = TrackFiber.new do
        yield
      end

      fiber.track = track
      fiber.resume
      
      # TODO If there are no listeners that are active then 
      # (keep in mind, that ASKs may have implicit listeners):
      if Server.listeners? then
        Server.global_track = track
        Server.boot
      else
        EM.stop
      end
    end
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