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

      def reset
        @initialized = false
      end

      def initialize(options = {})
        return if @initialized
        @initialized = true

        database_name = Config.get "database"

        begin
          connection = Mongo::Connection.new

          if options["reset"] then
            temp_db = connection.db(database_name)
            for collection in temp_db.collections
              collection.drop rescue nil
            end
          end

          ::Dog.database = connection.db(database_name)
        rescue Exception => e
          puts e
          raise "I was unable to connect to the MongoDB database. Is it running?"
        end

        # TODO - Add compound indices for queries.

        ::Dog.database[Community.collection_name].ensure_index("name", {unique:true})

        ::Dog.database[StreamObject.collection_name].ensure_index("type")
        ::Dog.database[StreamObject.collection_name].ensure_index("name")
        ::Dog.database[StreamObject.collection_name].ensure_index("created_at")

        # Indices for Tasks. Perhaps I should break this out into different collections?
        ::Dog.database[StreamObject.collection_name].ensure_index("replication")
        ::Dog.database[StreamObject.collection_name].ensure_index("responses")

        ::Dog.database[Person.collection_name].ensure_index("handle", { unique:true, sparse:true })
        ::Dog.database[Person.collection_name].ensure_index("email", { unique:true, sparse:true })
        ::Dog.database[Person.collection_name].ensure_index("facebook", { unique:true, sparse:true })
        ::Dog.database[Person.collection_name].ensure_index("twitter", { unique:true, sparse:true })
        ::Dog.database[Person.collection_name].ensure_index("google", { unique:true, sparse:true })
        ::Dog.database[Person.collection_name].ensure_index("password")
        ::Dog.database[Person.collection_name].ensure_index("communities")

        ::Dog.database[Track.collection_name].ensure_index("depth")
        ::Dog.database[Track.collection_name].ensure_index("ancestors")
      end
    end
  end
end
