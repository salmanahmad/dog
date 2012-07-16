#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog::Nodes
  
  class Treetop::Runtime::SyntaxNode
    def compile
      if elements && elements.first then
        return self.elements.first.compile  
      else
        return nil
      end
      
    end
  end
  
  class Node
    
    def visit(track)
      
    end
    
    def nodes
      
    end
    
  end
  
  class Nodes < Node
    attr_accessor :nodes
    
    def initialize
      self.nodes = []
    end
  end
  
  class Access < Node
    attr_accessor :sequence
  end
  
  class Assignment < Node
    attr_accessor :expression
    attr_accessor :sequence
  end
  
  class FunctionDefinition < Node
    
  end
  
  class OperatorInfixCall < Node
    attr_accessor :operator
    attr_accessor :arg1
    attr_accessor :arg2
  end
  
  class OperatorPrefixCall < Node
    attr_accessor :operator
    attr_accessor :arg
  end
  
  class FunctionCall < Node
    attr_accessor :function_name
    attr_accessor :mandatory_arguments
    attr_accessor :optional_arguments
  end
  
  class FunctionAsyncCall < Node
    attr_accessor :function_name
    attr_accessor :mandatory_arguments
    attr_accessor :optional_arguments
    attr_accessor :via
  end
  
  class StructureDefinition < Node
    
  end
  
  class StructureInstantiation < Node
    
  end
  
  class If < Node
    attr_accessor :conditions
  end
  
  class While < Node
    attr_accessor :condition
    attr_accessor :statements
  end
  
  class For < Node
    attr_accessor :variable
    attr_accessor :collection
    attr_accessor :statements
  end
  
  class Perform < Node
    
  end
  
  class Break < Node
    
  end
  
  class Return < Node
    attr_accessor :expression
  end
  
  class Print < Node
    attr_accessor :expression
  end
  
  class Inspect < Node
    attr_accessor :expression
  end
  
  
  class LiteralNode
    attr_accessor :value
  end
  
  class StructureLiteral < LiteralNode
    attr_accessor :type
    
    def initialize
      self.type = nil
    end
    
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