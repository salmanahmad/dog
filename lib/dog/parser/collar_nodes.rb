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
    
    def to_collar
      to_hash
    end
    
    def to_hash
      hash = {}
      hash[:offset] = self.interval.first
      hash[:text_value] = self.text_value
      hash[:name] = self.class.name
      unless self.elements.nil?
        hash[:elements] = self.elements.map {|element| element.to_hash() }
      else
        hash[:elements] = nil
      end
      return hash
    end
    
  end
  
  class CollarNode < Treetop::Runtime::SyntaxNode
  end
  
  class Program < CollarNode 
  end
  
  class ProgramStatements < CollarNode 
  end
  
  class Statements < CollarNode 
  end
  
  class TopLevelStatement < CollarNode 
  end
  
  class Statement < CollarNode 
  end
  
  class Primary < CollarNode 
  end
  
  class Access < CollarNode
  end
  
  class AccessDot < CollarNode 
  end
  
  class AccessBracket < CollarNode 
  end
  
  class AccessPossessive < CollarNode 
  end
  
  class AccessVariable < CollarNode 
  end
  
  class AccessPath < CollarNode 
  end
  
  class AccessPathItem < CollarNode 
  end
  
  class Assignment < CollarNode 
  end
  
  class Operation < CollarNode 
  end
  

  

  
  
  
  
  class Config < CollarNode 
  end
  
  class Import < CollarNode 
  end
  
  class ImportFunction < CollarNode 
  end
  
  class ImportData < CollarNode 
  end
  
  class ImportCommunity < CollarNode 
  end
  
  class ImportTask < CollarNode 
  end
  
  class ImportMessage < CollarNode 
  end
  
  class ImportConfig < CollarNode 
  end
  
  class Identifier < CollarNode 
  end
  
  class AssignmentOperator < CollarNode 
  end
  
  class TrueLiteral < CollarNode 
  end
  
  class FalseLiteral < CollarNode 
  end
  
  class IntegerLiteral < CollarNode 
  end
  
  class FloatLiteral < CollarNode 
  end
  
  class StringLiteral < CollarNode 
  end
  
  class ArrayLiteral < CollarNode 
  end
  
  class ArrayItems < CollarNode 
  end
  
  class ArrayItem < CollarNode 
  end
  
  class HashLiteral < CollarNode 
  end
  
  class HashAssociations < CollarNode 
  end
  
  class HashAssociation < CollarNode 
  end
  
  class AdditionOperator < CollarNode
  end
  
  class SubtractionOperator < CollarNode
  end
  
  class MultiplicationOperator < CollarNode
  end
  
  class DivisionOperator < CollarNode
  end
  
  class EqualityOperator < CollarNode
  end
  
  class InequalityOperator < CollarNode
  end
  
  class GreaterThanOperator < CollarNode
  end
  
  class LessThanOperator < CollarNode
  end
  
  class GreaterThanEqualOperator < CollarNode
  end
  
  class LessThanEqualOperator < CollarNode
  end
  
  class AndOperator < CollarNode
  end
  
  class OrOperator < CollarNode
  end
  
  class NotOperator < CollarNode
  end
  
  class UnionOperator < CollarNode
  end
  
  class IntersectOperator < CollarNode
  end
  
  class DifferenceOperator < CollarNode
  end
  
  class AppendOperator < CollarNode
  end
  
  class PrependOperator < CollarNode
  end
  
  class AssociatesOperator < CollarNode
  end
  
  class ContainsOperator < CollarNode
  end
  

  class Listen < CollarNode
  end 
  
  class ListenToClause < CollarNode
  end
  
  class ListenAtClause < CollarNode
  end
  
  class ListenForClause < CollarNode
  end
  
  class Ask < CollarNode
  end
  
  class Notify < CollarNode
  end
  
  class NotifyOfClause < CollarNode
  end
  
  class Compute < CollarNode
  end
  
  
  
  class UsingClause < CollarNode
  end
  
  class OnClause < CollarNode
  end

  class OnClauseItems < CollarNode
  end  

  class OnClauseItem < CollarNode
  end
    
    
    
  class ViaClause < CollarNode
  end
  
  class InClause < CollarNode
  end
  
  
  class IdentifierAssociations < CollarNode
  end
  
  class IdentifierAssociation < CollarNode
  end
  
  
  
  class Me < CollarNode
  end
  
  class Public < CollarNode
  end
  
  class Person < CollarNode
  end
  
  class People < CollarNode
  end
  
  class PeopleFromClause < CollarNode
  end
  
  class PeopleWhereClause < CollarNode
  end
  
  class KeyPaths < CollarNode
  end
  
  class KeyPath < CollarNode
  end
  
  class Predicate < CollarNode
  end
  
  class PredicateBinary < CollarNode
  end
  
  class PredicateUnary < CollarNode
  end
  
  class PredicateConditonal < CollarNode
  end
  
  class Function < CollarNode
  end
  
  class FunctionParameters < CollarNode
  end
  
  class FunctionParameter < CollarNode
  end
  
  class FunctionOn < CollarNode
  end
  
  class FunctionUsing < CollarNode
  end
  
  class FunctionOptionalParameters < CollarNode
  end
  
  class FunctionOptionalParameter < CollarNode
  end  
  
  


  class On < CollarNode
  end
  
  
  class Repeat < CollarNode
  end
  
  class If < CollarNode
  end
  
  class For < CollarNode
  end
  
  class Break < CollarNode
  end
  
  class Print < CollarNode
  end
  
  class Inspect < CollarNode
  end
  
  
end