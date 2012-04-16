#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  class Collection
    def self.named(name)
      collection_name = "dog." + name.to_s
      ::Dog.database[collection_name]
    end
  end
end