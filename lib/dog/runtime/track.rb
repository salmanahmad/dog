#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class Track
    
    attr_accessor :name
    attr_accessor :parent
    attr_accessor :children
    
    attr_accessor :fiber
    
    def initialize
      self.name = UUID.new.generate
    end
    
    def self.current
      track = Fiber.current.track
      
      if track.nil?
        raise "Attempting to access a track outside of a fiber"
      end
      
      return track
    end
    
  end
  
end