#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class Event < Structure
        
  end
  
  class SystemEvent < Event
    def self.identifier
      self.name.downcase.split("::")[1..-1].join(".")
    end
  end
  
end