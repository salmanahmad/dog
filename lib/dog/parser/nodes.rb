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
    
  end
  
  class Node < Treetop::Runtime::SyntaxNode
    
    attr_accessor :filename
    attr_accessor :line
    
    def path
      path = []
      
      if self.parent then
        index = 0
        
        for element in self.parent.elements do
          break if element.object_id == self
          index += 1
        end
        
        path = self.parent.path
        path << index
      end
      
      return path
    end
    
    def to_bark
      to_hash
    end
    
    def self.from_bark(bark)
      self.from_hash(bark)
    end
    
    def to_hash
      # TODO: Update this so that input is not saved every single time for every node.
      # That causes my output compiled code to be much smaller...
      
      hash = {}
      
      hash["interval_begin"] = self.interval.begin
      hash["interval_end"] = self.interval.end
      hash["interval_exclusive"] = self.interval.exclude_end?
      hash["input"] = self.input
      hash["text_value"] = self.text_value
      hash["name"] = self.class.name
      hash["filename"] = self.filename
      hash["line"] = self.line
      
      unless self.elements.nil?
        hash["elements"] = self.elements.map do |element|
          element.to_hash
        end
      else
        hash["elements"] = []
      end
      
      return hash
    end
    
    def self.from_hash(hash)
      internal = Range.new(hash["interval_begin"], hash["interval_end"], hash["interval_exclusive"])
      input = hash["input"]
      text_value = hash["text_value"]
      name = hash["name"]
      filename = hash["filename"]
      line = hash["line"]
      
      node_type = Object::const_get(name)
      node = node_type.new(input, interval, elements)
      node.filename = filename
      node.line = line
      
      elements = hash["elements"]
      elements.map! do |element|
        element = self.from_hash(element)
        element.parent = node
        element
      end
      
      return node
    end
    
  end
  
  # ================
  # = Core Program =
  # ================
  
  class Program < Node
    
  end
  
  class Statements < Node
    
  end
  
  class Statement < Node
    
  end
  
  # ==============
  # = Statements =
  # ==============
  
  class Assignment < Node
    
  end
  
  class Expression < Node
    
  end

  class Operation < Node
    
  end
  
  class OperationHead < Node
    
  end

  class Access < Node
    
  end
  
  class AccessHead < Node
    
  end

  class AccessTail < Node
    
  end
  
  class AccessBracket < Node
    
  end
  
  class AccessDot < Node
    
  end
  
  class Identifier < Node
    
  end
  
  # =============
  # = Operators =
  # =============
  
  class AssignmentOperator < Node
    
  end
  
  class AdditionOperator < Node
    
  end
  
  class SubtractionOperator < Node
    
  end
  
  class MultiplicationOperator < Node
    
  end
  
  class DivisionOperator < Node
    
  end
  
  class EqualityOperator < Node
    
  end
  
  class InequalityOperator < Node
    
  end
  
  class GreaterThanOperator < Node
    
  end
  
  class LessThanOperator < Node
    
  end
  
  class GreaterThanEqualOperator < Node
    
  end
  
  class LessThanEqualOperator < Node
    
  end
  
  class AndOperator < Node
    
  end
  
  class OrOperator < Node
    
  end
  
  class NotOperator < Node
    
  end
  
  class UnionOperator < Node
    
  end
  
  class IntersectOperator < Node
    
  end
  
  class DifferenceOperator < Node
    
  end
  
  class AppendOperator < Node
    
  end
  
  class PrependOperator < Node
    
  end
  
  class AssociatesOperator < Node
    
  end
  
  class ContainsOperator < Node
    
  end
  
  # ============
  # = Commands =
  # ============

  class Community < Node
    
  end
    
  class Community < Node
    
  end
  
  class CommunityProperties < Node
    
  end
  
  class CommunityProperty < Node
    
  end
  
  class CommunityPropertyAttribute < Node
    
  end
  
  class CommunityPropertyRelationship < Node
    
  end
  
  class CommunityPropertyRelationshipInverse < Node
    
  end
  
  class CommunityPropertyRelationshipInverseCommunity < Node
    
  end
  
  class Event < Node
    
  end
  
  class Task < Node
    
  end
  
  class Message < Node
    
  end
  
  class Properties < Node
    
  end
  
  class Property < Node
    
  end
  
  class PropertyDefaultValue < Node
    
  end
  
  class PropertyRequirementModifier < Node
    
  end
  
  class Listen < Node
   
  end 
  
  class ListenToClause < Node
    
  end
  
  class ListenForClause < Node
    
  end
  
  class ListenAtClause < Node
    
  end
  
  class Allow < Node
    
  end
  
  class AllowModifier < Node
    
  end
  
  class AllowProfile < Node
    
  end
  
  class Ask < Node
    
  end
  
  class AskToClause < Node
    
  end
  
  class Notify < Node
    
  end
  
  class NotifyOfClause < Node
    
  end
  
  class Reply < Node
    
  end
  
  class ReplyWithClause < Node
    
  end
  
  class Compute < Node
    
  end
  
  class On < Node
    
  end
  
  class Me < Node
    
  end
  
  class Public < Node
    
  end
  
  class Person < Node
    
  end
  
  class People < Node
    
  end
  
  class Predicate < Node
    
  end
  
  class PeopleFromClause < Node
    
  end
  
  class PeopleWhereClause < Node
    
  end
  
  class PredicateBinary < Node
    
  end
  
  class PredicateUnary < Node
    
  end
  
  class PredicateConditonal < Node
    
  end
  
  # ===============
  # = Definitions =
  # ===============
  
  class DefineVariable < Node
    
  end
  
  class DefineFunction < Node
    
    def name
      return self.elements[0].text_value
    end
    
  end
  
  class FunctionOn < Node
    
  end
  
  class FunctionUsing < Node
    
  end
  
  class FunctionOptionalParameters < Node
    
  end
  
  class FunctionOptionalParameter < Node
    
  end
  
  # ==================
  # = Other Commands =
  # ==================
  
  class Config < Node
    
  end
  
  class Import < Node
    
  end
  
  class ImportAsClause < Node
    
  end
  
  class ImportFunction < Node
    
  end
  
  class ImportData < Node
    
  end
  
  class ImportCommunity < Node
    
  end
  
  class ImportTask < Node
    
  end
  
  class ImportMessage < Node
    
  end
  
  class ImportConfig < Node
    
  end
  
  class Print < Node
    
  end
  
  class Inspect < Node
    
  end
  
  # ======================
  # = Control Structures =
  # ======================
  
  class Repeat < Node
    
  end
  
  class If < Node
    
  end
  
  class ElseClause < Node
    
  end
  
  class For < Node
    
  end
  
  class Break < Node
    
  end
  
  class Return < Node
    
  end
  
  class ReturnExpression < Node
    
  end
  
  # ==================
  # = Shared Clauses =
  # ==================
  
  class UsingClause < Node
    
  end
  
  class OnClause < Node
    
  end
  
  class ViaClause < Node
    
  end
  
  class InClause < Node
    
  end
  
  # =========
  # = Lists =
  # =========
  
  class KeyPaths < Node
    
  end
  
  class KeyPath < Node
    
  end
  
  class IdentifierAssociations < Node
    
  end
  
  class IdentifierAssociation < Node
    
  end
  
  class IdentifierList < Node
    
  end
  
  class IdentifierListItem < Node
    
  end
  
  class ArgumentList < Node
    
  end
  
  class ArgumentListItem < Node
    
  end
  
  # ===========
  # = Literal =
  # ===========
  
  class ArrayLiteral < Node
    
  end
  
  class ArrayItems < Node
    
  end
  
  class ArrayItem < Node
    
  end
  
  class HashLiteral < Node
    
  end
  
  class HashAssociations < Node
    
  end
  
  class HashAssociation < Node
    
  end
  
  class StringLiteral < Node
    
  end
  
  class IntegerLiteral < Node
    
  end
  
  class FloatLiteral < Node
    
  end
  
  class TrueLiteral < Node
    
  end
  
  class FalseLiteral < Node
    
  end

end