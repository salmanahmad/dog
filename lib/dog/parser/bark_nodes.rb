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
    
    def to_tag
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
  
  class Config < BarkNode 
  end
  
  class Import < BarkNode 
  end
  
  class ImportFunction < BarkNode 
  end
  
  class ImportData < BarkNode 
  end
  
  class ImportCommunity < BarkNode 
  end
  
  class ImportTask < BarkNode 
  end
  
  class ImportMessage < BarkNode 
  end
  
  class ImportConfig < BarkNode 
  end
  
  class Identifier < BarkNode 
  end
  
  class AssignmentOperator < BarkNode 
  end
  
  class TrueLiteral < BarkNode 
  end
  
  class FalseLiteral < BarkNode 
  end
  
  class IntegerLiteral < BarkNode 
  end
  
  class FloatLiteral < BarkNode 
  end
  
  class StringLiteral < BarkNode 
  end
  
  class ArrayLiteral < BarkNode 
  end
  
  class ArrayItems < BarkNode 
  end
  
  class ArrayItem < BarkNode 
  end
  
  class HashLiteral < BarkNode 
  end
  
  class HashAssociations < BarkNode 
  end
  
  class HashAssociation < BarkNode 
  end
  
  
  
end