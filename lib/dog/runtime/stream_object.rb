#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.join(File.dirname(__FILE__), '../helper.rb')

module Dog
  class StreamObject < DatabaseObject
    include Routability
    collection "stream"
    
    attr_accessor :_id
    attr_accessor :track_id
    attr_accessor :type
    attr_accessor :name
    attr_accessor :properties
    attr_accessor :routing
    attr_accessor :handler
    attr_accessor :handler_argument
    attr_accessor :created_at
    
    def self.inherited(child)
      child.collection "stream"
    end
    
    def initialize
      self.type = self.class
    end
    
    def self.from_hash(hash)
      klass = Kernel.qualified_const_get(hash["type"])
      object = klass.new
      
      for key, value in hash do
        object.instance_variable_set("@#{key}".intern, value)
      end
      
      object.type = Kernel.qualified_const_get(object.type)
      object.routing = People.from_database(object.routing || "{}")
      object.properties = object.properties.map { |property|
        Property.from_hash(property)
      }
      return object
    end
    
    def to_hash
      return {
        "track_id" => self.track_id,
        "type" => self.type.name,
        "name" => self.name,
        "properties" => ((self.properties || []).map { |property|
          property.to_hash
        }),
        "routing" => People.to_database(self.routing || {}),
        "handler" => self.handler,
        "handler_argument" => self.handler_argument,
        "created_at" => (self.created_at || Time.now)
      }
    end
    
    def to_hash_for_stream
      hash = to_hash
      hash.delete("_id")
      hash["id"] = self.id.to_s
      hash["track_id"] = self.track_id.to_s
      hash["name"] = hash["name"].split('.')
      hash["type"] = case self.type.name
      when 'Dog::RoutedEvent'
        'listen'
      when 'Dog::RoutedMessage'
        'notify'
      when 'Dog::RoutedTask'
        'ask'
      else
        raise 'Invalid StreamObject type: ' + self.type.name
      end
      # FIXME HACK -- remove this once the name is pluralized properly on backend
      if hash["type"] == 'listen'
        hash["name"][-1] = Helper::pluralize( hash["name"][-1] )
      end
      return hash
    end
    
  end
end

