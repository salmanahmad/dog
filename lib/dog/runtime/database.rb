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
        
        ::Dog.database[Community.collection_name].ensure_index("name", {unique:true})
        
        ::Dog.database[Message.collection_name].ensure_index("type")
        ::Dog.database[Message.collection_name].ensure_index("created_at")

        ::Dog.database[Person.collection_name].ensure_index("handle", { unique:true, sparse:true })
        ::Dog.database[Person.collection_name].ensure_index("email", { unique:true, sparse:true })
        ::Dog.database[Person.collection_name].ensure_index("facebook", { unique:true, sparse:true })
        ::Dog.database[Person.collection_name].ensure_index("twitter", { unique:true, sparse:true })
        ::Dog.database[Person.collection_name].ensure_index("google", { unique:true, sparse:true })
        ::Dog.database[Person.collection_name].ensure_index("password")
        ::Dog.database[Person.collection_name].ensure_index("communities")
        
        ::Dog.database[Task.collection_name].ensure_index("type")
        ::Dog.database[Task.collection_name].ensure_index("created_at")
        ::Dog.database[Task.collection_name].ensure_index("replication")
        ::Dog.database[Task.collection_name].ensure_index("responses")
        
        ::Dog.database[Track.collection_name].ensure_index("depth")
        ::Dog.database[Track.collection_name].ensure_index("ancestors")
        
        ::Dog.database[Variable.collection_name].ensure_index("name")
        ::Dog.database[Variable.collection_name].ensure_index("track_id")
        ::Dog.database[Variable.collection_name].ensure_index("track_depth")
        
        ::Dog.database[Workflow.collection_name].ensure_index("type")        
      end 
    end
  end    
end
