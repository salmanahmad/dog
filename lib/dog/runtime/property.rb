#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class Property
    attr_accessor :identifier
  end
  
  class CommunityAttribute
    attr_accessor :identifier
  end
  
  class CommunityRelationship
    attr_accessor :identifier
    attr_accessor :inverse_identifier
    attr_accessor :inverse_community
  end
  
end