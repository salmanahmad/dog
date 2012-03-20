#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class Collection < Structure
    
    def initialize
      @data = []
    end
    
    def find(query = {})
      if query == {} then
        resultset = @data
      else
        resultset = []
        for item in @data do
          match = true
          for key, value in query do
            if item[key] != value then
              match = false
              break
            end
          end
          
          resultset << item if match
        end
      end
      
      return resultset
    end    
    
    def add(item)
      @data << item
    end
    
  end
  
end