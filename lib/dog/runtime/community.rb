#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  class Community < DatabaseObject
    collection "communities"
    
    attr_accessor :_id
    attr_accessor :name
    attr_accessor :properties
    
    def self.establish(name, &block)
      community = self.find_by_name(name)
      
      unless community then
        community = Community.new
        community.name = name
      end
      
      members = Class.new Structure
      puts members
      members.instance_eval &block
      
      community.properties = members.properties
      
      community.save
      return community
    end
        
    def self.find_by_name(name)
      community = ::Dog.database[self.collection_name].find_one({
        "name" => name
      })
      
      if community then
        return self.from_hash(community)
      else
        return nil
      end
    end
      
    def to_hash
      return {
        name: self.name,
        properties: self.properties
      }
    end
  end
end