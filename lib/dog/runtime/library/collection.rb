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
    include ::Dog::NativePackage

    name "collection"

    implementation "save" do
      argument "struct"
      argument "collection"

      body do
        collection = collection.ruby_value["name"]
        ::Dog.database[collection].save(struct.to_hash)
        return ::Dog::Value.true_value
      end
    end
    
    implementation "delete" do
      argument "struct"
      argument "collection"

      body do
        collection = collection.ruby_value["name"]
        ::Dog.database[collection].remove({"_id" => struct._id})
        return ::Dog::Value.true_value
      end
    end
  end
end
