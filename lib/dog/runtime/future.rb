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
    attr_accessor :value_id
    attr_accessor :value
    attr_accessor :queue
    attr_accessor :tracks
    attr_accessor :handlers
    
    def initialize(id = nil, value = nil)
      self.value_id = id
      self.value = value
      self.queue = []
      self.tracks = []
      self.handlers = []
    end
    
    def to_hash
      tracks = self.tracks.map do |item|
        if item.kind_of? Track then
          item.save
          item._id
        elsif item.kind_of? BSON::ObjectId then
          item
        else
          raise "An invalid object appeared in the tracks list for a future"
        end
      end
      
      handlers = self.handlers.map do |handler|
        handler.to_hash
      end
      
      queue = self.queue.map do |value|
        value.to_hash
      end
      
      hash = {
        "value_id" => self.value_id,
        "value" => self.value.to_hash,
        "queue" => queue,
        "tracks" => tracks,
        "handlers" => handlers
      }
      
      return hash
    end
    
    def self.from_hash(hash)
      object = super
      object.value = ::Dog::Value.from_hash(object.value)
      
      object.queue = object.queue.map do |item|
        ::Dog::Value.from_hash(item)
      end
      
      return object
    end
  end
end