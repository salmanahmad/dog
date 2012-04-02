#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  class RoutedTask < DatabaseObject
    collection "tasks"
    
    attr_accessor :_id
    attr_accessor :type
    attr_accessor :value
    attr_accessor :routing
    attr_accessor :replication
    attr_accessor :duplication
    attr_accessor :responses
    attr_accessor :created_at
    
    def self.from_hash
      # TODO
    end
    
    def to_hash
      
    end
  end
  
  class Task < Structure
    
  end
end

