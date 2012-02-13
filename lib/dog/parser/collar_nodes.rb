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
  
  module CompileChild
    def compile
      if self.elements.size == 1 then
        return self.elements.first.compile
      elsif self.elements.size == 0
        return nil
      else
        raise "#{self.class.name} has more than 1 child."
      end
    end
  end
  
  class CollarNode < Treetop::Runtime::SyntaxNode
    def compile
      raise "Error: Attempting to compile a base Collar node."
    end
    
    def run
      raise "Error: Attempting to run a base Collar node."
    end
  end
  
  class Program < CollarNode
    def compile
      program = State.new
      self.elements.each do |node|
        state = node.compile
        program.children << state unless state.nil?
      end
      return program
    end
  end
  
  # TODO - At some point I need to return a state, where does that take place???
  class ProgramStatements < CollarNode
    include CompileChild
  end
  
  class Statements < CollarNode 
    include CompileChild
  end
  
  class TopLevelStatement < CollarNode 
    include CompileChild
  end
  
  class Statement < CollarNode
    include CompileChild
  end
  
  class Primary < CollarNode 
    include CompileChild
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
  
  class Identifier < CollarNode 
  end
  
  class AssignmentOperator < CollarNode 
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
  
  class If < CollarNode
  end
  
  class For < CollarNode
  end
  
  class Repeat < CollarNode
  end
  
  class Break < CollarNode
  end
  
  class Print < CollarNode
  end
  
  class Inspect < CollarNode
  end
  
  class ArrayLiteral < CollarNode 
    def compile
      items = self.elements.first
      if items then
        return items.compile
      else
        return []
      end
    end
  end
  
  class ArrayItems < CollarNode
    def compile
      items = []
      for element in self.elements do
        items << element.compile
      end
      return items
    end
  end
  
  class ArrayItem < CollarNode 
    include CompileChild
  end
  
  class HashLiteral < CollarNode 
    def compile
      associations = self.elements.first
      if associations then
        return associations.compile
      else
        return {}
      end
    end
  end
  
  class HashAssociations < CollarNode 
    def compile
      associations = {}
      for element in self.elements do
        association = element.compile
        for key, value in association do
          associations[key] = value
        end
      end
      return associations
    end
  end
  
  class HashAssociation < CollarNode 
    def compile
      association = {}
      key = self.elements[0].compile
      value = self.elements[1].compile
      association[key] = value
      return association
    end
  end
  
  class StringLiteral < CollarNode 
    def compile
      string = self.text_value
      quote = string[0]
      string = string[1..-2]
      string.gsub!("\\#{quote}", quote)
      return string
    end
  end
  
  class IntegerLiteral < CollarNode 
    def compile
      Integer(self.text_value)
    end
  end
  
  class FloatLiteral < CollarNode 
    def compile
      Float(self.text_value)
    end
  end
  
  class TrueLiteral < CollarNode 
    def compile
      return true
    end
  end
  
  class FalseLiteral < CollarNode 
    def compile
      return false
    end
  end
  
end