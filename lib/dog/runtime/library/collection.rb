#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog::Library
  module Collection
    # TODO - I need to validate and ensure the correct structure type are being used
    
    # TODO - Technically speaking, a developer can create their own structure with the
    # appropriate type and value
    
    # TODO - All native methods must return a value
    
    def self.name
      "collection"
    end
    
    def self.symbols
      return {
        "save" => Save.new,
        "delete" => Delete.new
      }
    end
    
    class Save < ::Dog::NativeFunction
      def run(args = nil, optionals = nil)
        struct = args[0]
        collection = args[1]
      
        collection = collection.ruby_value["name"]
        ::Dog.database[collection].save(struct.to_hash)
      
        return ::Dog::Value.true_value
      end
    end
    
    class Delete < ::Dog::NativeFunction
      def run(args = nil, optionals = nil)
        struct = args[0]
        collection = args[1]
      
        collection = collection.ruby_value["name"]
        ::Dog.database[collection].remove({"_id" => struct._id})
      
        return ::Dog::Value.true_value
      end
    end
    
  end
end
