#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class << self 
    attr_accessor :database    
  end
  
  module Database
    
    include Dog
    
    class << self
      
      def initialize
        return if @initialized
        @initialized = true
        
        database_name = Config.get "database"

        if connection then
          ::Dog.database = Mongo::Connection.new.db(database_name)
        else
          ::Dog.database = Mongo::Connection.new.db($0)
        end
        
        # TODO - Ensure Indices
        
        # Variable - name
        # Variable - track_id
        
        
      end 
    end
  end    
end
