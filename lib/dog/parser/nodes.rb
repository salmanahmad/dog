#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog::Nodes
  
  class Node
    
    def visit(track)
      
    end
    
  end
  
  class Nodes < Node
    
  end
  
  class Access < Node
    
  end
  
  class Assignment < Node
    
  end
  
  class FunctionDefinition < Node
    
  end
  
  class OperatorBinaryCall < Node
    
  end
  
  class OperatorUnaryCall < Node
    
  end
  
  class FunctionCall < Node
    
  end
  
  class FunctionAsyncCall < Node
    
  end
  
  class StructureDefinition < Node
    
  end
  
  class StructureInstantiation < Node
    
  end
  
  class If < Node
    
  end
  
  class While < Node
    
  end
  
  class For < Node
    
  end
  
  class Break < Node
    
  end
  
  class Return < Node
    
  end
  
  class LiteralNode
    attr_accessor :value
    
    def initialize(value)
      self.value = value
    end
  end
  
  class StructureLiteral < LiteralNode
    
    def visit(track)
      
    end
    
  end
  
  class StringLiteral < LiteralNode
    
  end
  
  class NumberLiteral < LiteralNode
    
  end
  
  class TrueLiteral < LiteralNode
    
  end
  
  class FalseLiteral < LiteralNode
    
  end
  
  class NullLiteral < LiteralNode
    
  end
  
end