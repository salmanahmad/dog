#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class Track < Sequel::Model(:tracks)
            
    attr_accessor :context
    attr_accessor :fiber
    
    def initialize
      self.context = {}
    end
    
    def parent
      self.class.filter(:id => self.parent_id).first
    end
    
    def children
      self.class.filter(:parent_id => self.id).all
    end
   
    def fiber=(f)
      @fiber = f
      f.instance_variable_set(:@track, self.id)
    end
    
    def checkpoint &block
      # TODO
    end

    def reset_checkpoint &block
      # TODO
    end
    
    def self.root
      return @root if @root
      @root = Track.find_or_create(:root => true)
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