#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  class Future < DatabaseObject
    collection "futures"
    
    attr_accessor :_id
    attr_accessor :structure_id
    attr_accessor :value
    attr_accessor :tracks
    attr_accessor :handlers
    
    def initialize(id, value)
      self.structure_id = id
      self.value = value
      self.tracks = []
      self.handlers = []
    end
    
    def to_hash
      hash = {
        "future_id" => self.structure_id,
        "value" => self.value.to_hash,
        "tracks" => self.tracks,
        "handlers" => self.handlers
      }
      
      return hash
    end
    
    def self.from_hash(hash)
      object = super
      object.value = ::Dog::Value.from_hash(object.value)
      
      return object
    end
  end
end