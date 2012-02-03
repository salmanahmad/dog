#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class Treetop::Runtime::SyntaxNode
    
    def to_bark
      to_hash
    end
    
    def to_hash
      hash = {}
      hash[:offset] = self.interval.first
      hash[:text_value] = self.text_value
      hash[:name] = self.class.name.split("::").last
      unless( self.elements.nil? )
        hash[:elements] = self.elements.map {|element| element.to_hash() }
      else
        hash[:elements] = nil
      end
      return hash
    end
    
  end
  
  class BarkNode < Treetop::Runtime::SyntaxNode 
  end
  
  
  
end