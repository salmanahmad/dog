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
  
  class Program < BarkNode 
  end
  
  class ProgramStatements < BarkNode 
  end
  
  class Statements < BarkNode 
  end
  
  class TopLevelStatement < BarkNode 
  end
  
  class Statement < BarkNode 
  end
  
  class Primary < BarkNode 
  end
  
  class Access < BarkNode
  end
  
  class AccessDot < BarkNode 
  end
  
  class AccessBracket < BarkNode 
  end
  
  class AccessPossessive < BarkNode 
  end
  
  class AccessVariable < BarkNode 
  end
  
  class AccessPath < BarkNode 
  end
  
  class AccessPathItem < BarkNode 
  end
  
  class Assignment < BarkNode 
  end
  
  class Operation < BarkNode 
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
  
  class AdditionOperator < BarkNode
  end
  
  class SubtractionOperator < BarkNode
  end
  
  class MultiplicationOperator < BarkNode
  end
  
  class DivisionOperator < BarkNode
  end
  
  class EqualityOperator < BarkNode
  end
  
  class InequalityOperator < BarkNode
  end
  
  class GreaterThanOperator < BarkNode
  end
  
  class LessThanOperator < BarkNode
  end
  
  class GreaterThanEqualOperator < BarkNode
  end
  
  class LessThanEqualOperator < BarkNode
  end
  
  class AndOperator < BarkNode
  end
  
  class OrOperator < BarkNode
  end
  
  class NotOperator < BarkNode
  end
  
  class UnionOperator < BarkNode
  end
  
  class IntersectOperator < BarkNode
  end
  
  class DifferenceOperator < BarkNode
  end
  
  class AppendOperator < BarkNode
  end
  
  class PrependOperator < BarkNode
  end
  
  class AssociatesOperator < BarkNode
  end
  
  class ContainsOperator < BarkNode
  end
  
  
  class Repeat < BarkNode
  end
  
  class If < BarkNode
  end
  
  class For < BarkNode
  end
  
  class Break < BarkNode
  end
  

end