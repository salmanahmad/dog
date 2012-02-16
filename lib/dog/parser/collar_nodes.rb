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
  
  module CompileOperationState
    def compile
      state = OperationState.new
      state.operation = self
      return state
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
  
  module NotRunnable
    def run
      raise "Attempting to run an unrunnable node: #{self.class.name}."
    end
  end
  
  class CollarNode< Treetop::Runtime::SyntaxNode
    include NotRunnable
    include CompileOperationState
    # TODO - this default is somewhat problematic. For example, for clauses or predicates
  end
  
  class Program < CollarNode
    def compile
      program = ProgramState.new
      
      self.elements.each do |node|
        state = node.compile
        state.add_child(state)
      end
      
      return program
    end
  end
  
  class ProgramStatements < CollarNode
    include CompileChild
  end
  
  class Statements < CollarNode
    def compile
      states = []
      
      self.elements.each do |node|
        state = node.compile
        states << state
      end
      
      return states
    end
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
    def run
      
    end
  end 
  
  class ListenToClause < CollarNode
    def run
      
    end
  end
  
  class ListenAtClause < CollarNode
    def run
      
    end
  end
  
  class ListenForClause < CollarNode
    def run
      
    end
  end
  
  class Ask < CollarNode
    def run
      
    end
  end
  
  class Notify < CollarNode
    def run
      
    end
  end
  
  class NotifyOfClause < CollarNode
    def run
      
    end
  end
  
  class Compute < CollarNode
    def run
      
    end
  end
  
  class UsingClause < CollarNode
    def run
      
    end
  end
  
  class OnClause < CollarNode
    def run
      
    end
  end
  
  class OnClauseItems < CollarNode
    def run
      
    end
  end
  
  class OnClauseItem < CollarNode
    def run
      
    end
  end
  
  class ViaClause < CollarNode
    def run
      
    end
  end
  
  class InClause < CollarNode
    def run
      
    end
  end
  
  class IdentifierAssociations < CollarNode
    def run
      
    end
  end
  
  class IdentifierAssociation < CollarNode
    def run
      
    end
  end
  
  class Me < CollarNode
    def run
      
    end
  end
  
  class Public < CollarNode
    def run
      
    end
  end
  
  class Person < CollarNode
    def run
      
    end
  end
  
  class People < CollarNode
    def run
      
    end
  end
  
  class PeopleFromClause < CollarNode
    def run
      
    end
  end
  
  class PeopleWhereClause < CollarNode
    def run
      
    end
  end
  
  class KeyPaths < CollarNode
    def run
      
    end
  end
  
  class KeyPath < CollarNode
    def run
      
    end
  end
  
  class Predicate < CollarNode
    def run
      
    end
  end
  
  class PredicateBinary < CollarNode
    def run
      
    end
  end
  
  class PredicateUnary < CollarNode
    def run
      
    end
  end
  
  class PredicateConditonal < CollarNode
    def run
      
    end
  end
  
  class Config < CollarNode
    def run
      
    end
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
  
  ### Function stuff start
  
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
  
  ### Function stuff stop
  
  class On < CollarNode
    def compile
      state = nil
      
      if elements[1] then
        state = OnState.new
        state.dependency = elements[0]
        state.add_child(element[1].compile)
      end
      
      return state
    end
  end
  
  class If < CollarNode
    def compile
      state = nil
      
      if elements[0] then
        condition = elements[0]
        
        if elements[1] then
          element = elements[1]
          
          true_branch = ConditionState.new
          true_branch.condition = condition
          true_branch.add_child(element.compile)
          
          state = IfState.new
          state.add_child(true_branch)
        end
        
        if elements[2] then
          element = elements[2]
          
          false_branch = ConditionState.new
          false_branch.add_child(element.compile)
          
          state.add_child(false_branch)
        end
        
      end
      
      return state
    end
  end
  
  class ElseClause < CollarNode
    include CompileChild
  end
  
  class For < CollarNode
    def compile
      state = nil
      
      if elements[1] then
        state = ForState.new
        state.enumerable = elements[0]
        state.add_child(element[1].compile)
      end
      
      return state
    end
  end
  
  class Repeat < CollarNode
    def compile
      state = nil
      
      if elements[1] then
        state = RepeatState.new
        state.count = elements[0]
        state.add_child(element[1].compile)
      end
      
      return state
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