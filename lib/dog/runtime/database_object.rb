#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class DatabaseObject
    class << self
      attr_accessor :collection_name
    end
    
    def self.collection(name)
      self.collection_name = name
    end
    
    def save
      if self._id then
        ::Dog::database[self.class.collection_name].update({"_id" => self._id}, self.to_hash)
      else
        id = ::Dog::database[self.class.collection_name].insert(self.to_hash)
        self._id = id
      end
    end
    
  end    
end
