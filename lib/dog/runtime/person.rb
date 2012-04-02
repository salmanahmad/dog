#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  class Person < DatabaseObject
    collection "people"
    
    attr_accessor :_id
    attr_accessor :handle
    attr_accessor :email
    attr_accessor :facebook
    attr_accessor :twitter
    attr_accessor :google
    attr_accessor :password
    attr_accessor :communities
    attr_accessor :profile
    
    def self.from_variable
      
    end
    
  end

  class People
    
    def self.from
      
    end
    
    def self.where
      
    end
    
  end
end