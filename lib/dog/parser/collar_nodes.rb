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
      offset = hash[:offset]
      text_value = hash[:text_value]
      name = hash[:name]
      
      input = hash[:input]
      interval = hash[:interval]
      
      elements = hash[:elements]
      elements.map! do |element|
        element = self.from_hash(element)
      end
      
      node_type = Object::const_get(name)
      node = node_type.new(input, interval, elements)
      return node
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

  module RunChild
    def run
      if self.elements.size == 1 then
        return self.elements.first.run
      elsif self.elements.size == 0
        return nil
      else
        raise "#{self.class.name} has more than 1 child."
      end
    end
  end
  
  class CollarNode < Treetop::Runtime::SyntaxNode
    def compile
      state = State.new
      state.operation = self
      return state
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
        unless state.nil? then
          state.parent = program
          program.children << state 
        end
      end
      
      return program
    end
  end
  
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
  end
  
  class Access < CollarNode
  end
  
  class AccessBracket < CollarNode 
  end
  
  class AccessDot < CollarNode 
  end
  
  class AccessPossessive < CollarNode 
  end
  
  class Assignment < CollarNode
  end
  
  class Operation < CollarNode 
    def run
      elements[1].run(elements[0].run, elements[1].run)
    end
  end
  
  class Identifier < CollarNode 
  end
  
  class AssignmentOperator < CollarNode 
  end
  
  class AdditionOperator < CollarNode
    def run(arg1, arg2)
      arg1 + arg2
    end
  end
  
  class SubtractionOperator < CollarNode
    def run(arg1, arg2)
      arg1 - arg2
    end
  end
  
  class MultiplicationOperator < CollarNode
    def run(arg1, arg2)
      arg1 * arg2
    end
  end
  
  class DivisionOperator < CollarNode
    def run(arg1, arg2)
      arg1 / arg2
    end
  end
  
  class EqualityOperator < CollarNode
    def run(arg1, arg2)
      arg1 == arg2
    end
  end
  
  class InequalityOperator < CollarNode
    def run(arg1, arg2)
      arg1 != arg2
    end
  end
  
  class GreaterThanOperator < CollarNode
    def run(arg1, arg2)
      arg1 > arg2
    end
  end
  
  class LessThanOperator < CollarNode
    def run(arg1, arg2)
      arg1 < arg2
    end
  end
  
  class GreaterThanEqualOperator < CollarNode
    def run(arg1, arg2)
      arg1 >= arg2
    end
  end
  
  class LessThanEqualOperator < CollarNode
    def run(arg1, arg2)
      arg1 <= arg2
    end
  end
  
  class AndOperator < CollarNode
    def run(arg1, arg2)
      arg1 && arg2
    end
  end
  
  class OrOperator < CollarNode
    def run(arg1, arg2)
      arg1 || arg2
    end
  end
  
  class NotOperator < CollarNode
    def run(arg1)
      !arg1
    end
  end
  
  class UnionOperator < CollarNode
    def run(arg1, arg2)
      # TODO
    end
  end
  
  class IntersectOperator < CollarNode
    def run(arg1, arg2)
      # TODO
    end
  end
  
  class DifferenceOperator < CollarNode
    def run(arg1, arg2)
      # TODO
    end
  end
  
  class AppendOperator < CollarNode
    def run(arg1, arg2)
      # TODO
    end
  end
  
  class PrependOperator < CollarNode
    def run(arg1, arg2)
      # TODO
    end
  end
  
  class AssociatesOperator < CollarNode
    def run(arg1, arg2)
      # TODO
    end
  end
  
  class ContainsOperator < CollarNode
    def run(arg1, arg2)
      arg1.include? arg2
    end
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
    def run
      
    end
  end
  
  class ImportFunction < CollarNode 
    def run
      
    end
  end
  
  class ImportData < CollarNode 
    def run
      
    end
  end
  
  class ImportCommunity < CollarNode 
    def run
      
    end
  end
  
  class ImportTask < CollarNode 
    def run
      
    end
  end
  
  class ImportMessage < CollarNode 
    def run
      
    end
  end
  
  class ImportConfig < CollarNode 
    def run
      
    end
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
    def run
      # BIG TODO
    end
  end
  
  class If < CollarNode
    def run
      # BIG TODO
    end
  end
  
  class For < CollarNode
    def run
      # BIG TODO
    end
  end
  
  class Repeat < CollarNode
    def run
      # TODO
    end
  end
  
  class Break < CollarNode
    def run
      # TODO
    end
  end
  
  class Print < CollarNode
    def run
      puts elements.first
    end
  end
  
  class Inspect < CollarNode
    def run
      puts elements.first.inspect
    end
  end
  
  class ArrayLiteral < CollarNode 
    def run
      items = self.elements.first
      if items then
        return items.run
      else
        return []
      end
    end
  end
  
  class ArrayItems < CollarNode
    def run
      items = []
      for element in self.elements do
        items << element.run
      end
      return items
    end
  end
  
  class ArrayItem < CollarNode 
    include RunChild
  end
  
  class HashLiteral < CollarNode 
    def run
      associations = self.elements.first
      if associations then
        return associations.run
      else
        return {}
      end
    end
  end
  
  class HashAssociations < CollarNode 
    def run
      associations = {}
      for element in self.elements do
        association = element.run
        for key, value in association do
          associations[key] = value
        end
      end
      return associations
    end
  end
  
  class HashAssociation < CollarNode 
    def run
      association = {}
      key = self.elements[0].run
      value = self.elements[1].run
      association[key] = value
      return association
    end
  end
  
  class StringLiteral < CollarNode 
    def run
      string = self.text_value
      quote = string[0]
      string = string[1..-2]
      string.gsub!("\\#{quote}", quote)
      return string
    end
  end
  
  class IntegerLiteral < CollarNode 
    def run
      Integer(self.text_value)
    end
  end
  
  class FloatLiteral < CollarNode 
    def run
      Float(self.text_value)
    end
  end
  
  class TrueLiteral < CollarNode 
    def run
      return true
    end
  end
  
  class FalseLiteral < CollarNode 
    def run
      return false
    end
  end
  
end