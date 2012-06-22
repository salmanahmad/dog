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
    
    def to_collar
      to_hash
    end
    
    def self.from_collar(collar)
      self.from_hash(collar)
    end
    
    def to_hash
      hash = {}
      hash[:offset] = self.interval.first
      hash[:text_value] = self.text_value
      hash[:name] = self.class.name
      
      hash[:input] = self.input
      hash[:interval] = self.interval
      
      unless self.elements.nil?
        hash[:elements] = self.elements.map do |element|
          element.to_hash
        end
      else
        hash[:elements] = nil
      end
      
      return hash
    end
    
    def self.from_hash(hash)
      self.offset = hash[:offset]
      self.text_value = hash[:text_value]
      self.name = hash[:name]
      
      self.input = hash[:input]
      self.interval = hash[:interval]
      
      elements = hash[:elements]
      elements.map! do |element|
        element = self.from_hash(element)
      end
      
      node_type = Object::const_get(name)
      node = node_type.new(input, interval, elements)
      
      return node
    end
    
  end
  
  class CollarNode < Treetop::Runtime::SyntaxNode
    
  end
  
  # TODO - Remove FormattedString 
  # TODO - Remove CompilationContext
  
  # ================
  # = Core Program =
  # ================
  
  class Program < CollarNode
    
  end
  
  class Statements < CollarNode
    
  end
  
  class Statement < CollarNode
    
  end
  
  # ==============
  # = Statements =
  # ==============
  
  class Assignment < CollarNode
    
  end
  
  class Expression < CollarNode
    
  end

  class Operation < CollarNode
    
  end
  
  class OperationHead < CollarNode
    
  end

  class Access < CollarNode
    
  end
  
  class AccessHead < CollarNode
    
  end

  class AccessTail < CollarNode
    
  end
  
  class AccessBracket < CollarNode
    
  end
  
  class AccessDot < CollarNode
    
  end
  
  class Identifier < CollarNode
    
  end
  
  # =============
  # = Operators =
  # =============
  
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
  
  # ============
  # = Commands =
  # ============

  class Community < CollarNode
    
  end
  
  class Event < CollarNode
    
  end
  
  class Task < CollarNode
    
  end
  
  class Message < CollarNode
    
  end
  
  class Properties < CollarNode
    
  end
  
  class Property < CollarNode
    
  end
  
  class PropertyDefaultValue < CollarNode
    
  end
  
  class PropertyRequirementModifier < CollarNode
    
  end
  
  class Listen < CollarNode
   
  end 
  
  class ListenToClause < CollarNode
    
  end
  
  class ListenForClause < CollarNode
    
  end
  
  class ListenAtClause < CollarNode
    
  end
  
  class Allow < CollarNode
    
  end
  
  class AllowModifier < CollarNode
    
  end
  
  class AllowProfile < CollarNode
    
  end
  
  class Ask < CollarNode
    
  end
  
  class AskToClause < CollarNode
    
  end
  
  class Notify < CollarNode
    
  end
  
  class NotifyOfClause < CollarNode
    
  end
  
  class Reply < CollarNode
    
  end
  
  class ReplyWithClause < CollarNode
    
  end
  
  class Compute < CollarNode
    
  end
  
  class On < CollarNode
    
  end
  
  class Me < CollarNode
    
  end
  
  class Public < CollarNode
    
  end
  
  class Person < CollarNode
    
  end
  
  class People < CollarNode
    
  end
  
  class Predicate < CollarNode
    
  end
  
  class PeopleFromClause < CollarNode
    
  end
  
  class PeopleWhereClause < CollarNode
    
  end
  
  class PredicateBinary < CollarNode
    
  end
  
  class PredicateUnary < CollarNode
    
  end
  
  class PredicateConditonal < CollarNode
    
  end
  
  # ===============
  # = Definitions =
  # ===============
  
  class DefineVariable < CollarNode
    
  end
  
  class DefineFunction < CollarNode
    
  end
  
  class FunctionOn < CollarNode
    
  end
  
  class FunctionUsing < CollarNode
    
  end
  
  class FunctionOptionalParameters < CollarNode
    
  end
  
  class FunctionOptionalParameter < CollarNode
    
  end
  
  # ==================
  # = Other Commands =
  # ==================
  
  class Config < CollarNode
    
  end
  
  class Import < CollarNode
    
  end
  
  class ImportAsClause < CollarNode
    
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
  
  class Print < CollarNode
    
  end
  
  class Inspect < CollarNode
    
  end
  
  # ======================
  # = Control Structures =
  # ======================
  
  class Repeat < CollarNode
    
  end
  
  class If < CollarNode
    
  end
  
  class ElseClause < CollarNode
    
  end
  
  class For < CollarNode
    
  end
  
  class Break < CollarNode
    
  end
  
  class Return < CollarNode
    
  end
  
  # ==================
  # = Shared Clauses =
  # ==================
  
  class UsingClause < CollarNode
    
  end
  
  class OnClause < CollarNode
    
  end
  
  class ViaClause < CollarNode
    
  end
  
  class InClause < CollarNode
    
  end
  
  # =========
  # = Lists =
  # =========
  
  class KeyPaths < CollarNode
    
  end
  
  class KeyPath < CollarNode
    
  end
  
  class IdentifierAssociations < CollarNode
    
  end
  
  class IdentifierAssociation < CollarNode
    
  end
  
  class IdentifierList < CollarNode
    
  end
  
  class IdentifierListItem < CollarNode
    
  end
  
  class ArgumentList < CollarNode
    
  end
  
  class ArgumentListItem < CollarNode
    
  end
  
  # ===========
  # = Literal =
  # ===========
  
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
  
  class StringLiteral < CollarNode
    
  end
  
  class IntegerLiteral < CollarNode
    
  end
  
  class FloatLiteral < CollarNode
    
  end
  
  class TrueLiteral < CollarNode
    
  end
  
  class FalseLiteral < CollarNode
    
  end

end