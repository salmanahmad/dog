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
    attr_accessor :blocking_tracks
    attr_accessor :broadcast_tracks
    attr_accessor :handlers
    
    def initialize(id = nil, value = nil)
      self.value_id = id
      self.value = value
      self.queue = []
      self.blocking_tracks = []
      self.broadcast_tracks = []
      self.handlers = []
    end
    
    def self.remove_broadcast_track_from_all(track_id)
      self.update({
        "broadcast_tracks" => track_id
      }, { 
        "$pull" => { 
          "broadcast_tracks" => track_id 
        } 
      }, {
        :multi => true
      })
    end
    
    def to_hash
      blocking_tracks = self.blocking_tracks.map do |item|
        if item.kind_of? Track then
          item.save
          item._id
        elsif item.kind_of? BSON::ObjectId then
          item
        else
          raise "An invalid object appeared in the tracks list for a future"
        end
      end
      
      broadcast_tracks = self.broadcast_tracks.map do |item|
        if item.kind_of? Track then
          item.save
          item._id
        elsif item.kind_of? BSON::ObjectId then
          item
        else
          raise "An invalid object appeared in the tracks list for a future"
        end
      end
      
      queue = self.queue.map do |value|
        value.to_hash
      end
      
      value = self.value
      if self.value.nil? then
        value = nil
      else
        value = value.to_hash
      end
      
      hash = {
        "value_id" => self.value_id,
        "value" => value,
        "queue" => queue,
        "blocking_tracks" => blocking_tracks,
        "broadcast_tracks" => broadcast_tracks,
        "handlers" => handlers
      }
      
      return hash
    end
    
    def self.from_hash(hash)
      object = super
      
      if object.value != nil then
        object.value = ::Dog::Value.from_hash(object.value)
      end
      
      object.queue = object.queue.map do |item|
        ::Dog::Value.from_hash(item)
      end
      
      return object
    end
  end
end