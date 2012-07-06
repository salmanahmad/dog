#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog::Nodes
  
  module VisitOperator
    def visit(track)
      self.write_stack(track, self.text_value)
      return parent.path
    end
  end
  
  module VisitAllChildrenReturnLast
    def visit(track)
      path = super
      
      if path then
        return path
      else
        write_stack(track, elements.last.read_stack(track))
        if parent then
          return parent.path
        else
          return nil
        end
      end
    end
  end
  
  module VisitAllChildrenReturnAll
    def visit(track)
      path = super
      
      if path then
        return path
      else
        array = []
        
        for element in elements do
          array << element.read_stack(track)
        end
        
        write_stack(track, array)
        return parent.path
      end
    end
  end
  
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
          break if element.object_id == self.object_id
          index += 1
        end
        
        path = self.parent.path
        path << index
      end
      
      return path
    end
    
    def write_stack(track, value)
      path = self.path.clone
      last = path.pop
      
      return if last.nil?
      
      stack = track.stack
      for index in path do
        index = index.to_s
        stack[index] ||= {}
        stack = stack[index]
      end
      
      stack[last.to_s] = value
    end
    
    def read_stack(track)
      path = self.path.clone
      stack = track.stack
      
      begin
        for index in path do
          index = index.to_s
          stack = stack[index]
        end
        return stack
      rescue
        return nil
      end
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
      interval = Range.new(hash["interval_begin"], hash["interval_end"], hash["interval_exclusive"])
      input = hash["input"]
      text_value = hash["text_value"]
      name = hash["name"]
      filename = hash["filename"]
      line = hash["line"]
      
      elements = hash["elements"]
      
      elements.map! do |element|
        element = self.from_hash(element)
        element
      end
      
      # TODO - Look over this... Is it really necessary to prefix with the root namespace?
      node_type = Kernel::qualified_const_get(name)
      node = node_type.new(input, interval, elements)
      node.filename = filename
      node.line = line
      
      elements.each do |element|
        element.parent = node
      end
      
      
      return node
    end
    
    def elements_by_class(klass)
      result = []
      
      self.elements.each do |element|
        if element.class == klass then
          result << element
        end
      end
      
      result
    end
    
    def visit(track)
      # It is the node's responsibility to do whatever it needs to do
      # Then it needs to write some information to the "stack"
      # And then return the next node_path for the runtime to visit next
      
      for element in elements do
        if !track.has_stack_path(element.path) then
          return element.path
        end
      end
      
      return nil
    end
    
  end
  
  # ================
  # = Core Program =
  # ================
  
  class Program < Node
    def visit(track)
      path = super
      
      if path then
        return path
      else
        write_stack(track, elements.last.read_stack(track))
        track.state = ::Dog::Track::STATE::FINISHED
        return nil
      end
      
    end
  end
  
  class Statements < Node
    include VisitAllChildrenReturnLast
  end
  
  class Statement < Node
    include VisitAllChildrenReturnLast
  end
  
  # ==============
  # = Statements =
  # ==============
  
  class Assignment < Node
    def visit(track)
      path = super
      
      if path then 
        return path
      else
        value = elements.last.read_stack(track)
        path = elements.first.read_stack(track)
        
        # TODO - This may raise an exception...
        pointer = track.variables
        last = path.pop
        for index in path do
          pointer = pointer[index]
        end
        
        pointer[last] = value
        
        write_stack(track, value)
        return parent.path
      end
    end
  end
  
  
  class AssignmentAccess < Node
    def visit(track)
      path = super
      
      if path then
        return path
      else
        pointer = []
        pointer << elements.first.read_stack(track)
        
        tail = elements_by_class(AccessTail).first
        if tail then
          tail_pointer = tail.read_stack(track)
          for item in tail_pointer do
            pointer << item
          end
        end
        
        write_stack(track, pointer)
        return parent.path
      end
    end
  end
  
  class Expression < Node
    include VisitAllChildrenReturnLast
  end
  
  class Operation < Node
    def visit(track)
      path = super
      
      if path then
        return path
      else
        if elements.size == 2 then
          operand = elements.last.read_stack(track)
          value = elements.first.perform(operand)
          
          write_stack(track, value)
          return parent.path
        elsif elements.size == 3 then
          operand1 = elements[0].read_stack(track)
          operand2 = elements[2].read_stack(track)
          value = elements[1].perform(operand1, operand2)
          
          write_stack(track, value)
          return parent.path
        else
          raise "Executing an invalid operation"
        end
      end
    end
  end
  
  class OperationHead < Node
    include VisitAllChildrenReturnLast
  end
  
  class OperationTail < Node
    include VisitAllChildrenReturnLast
  end
  
  class Access < Node
    def visit(track)
      path = super
      
      if path then
        return path
      else
        value = elements.first.read_stack(track)
        
        pointer = elements_by_class(AccessTail).first
        if pointer then
          pointer = pointer.read_stack(track)
        else
          pointer = []
        end
        
        # TODO - This may raise an exception...
        for index in pointer do
          value = value[index]
        end
        
        write_stack(track, value)
        return parent.path
      end
      
    end
  end
  
  class AccessHead < Node
    include VisitAllChildrenReturnLast
  end
  
  class Variable < Node
    def visit(track)
      path = super
      
      if path then
        return path
      else
        variable_name = elements.first.read_stack(track)
        write_stack(track, track.variables[variable_name])
        return parent.path
      end
    end
  end
  
  class AccessTail < Node
    include VisitAllChildrenReturnLast
  end
  
  class AccessBracket < Node
    def visit(track)
      path = super

      if path then
        return path
      else
        pointer = []
        pointer << elements.first.read_stack(track)

        tail = elements_by_class(AccessTail).first
        if tail then
          tail_pointer = tail.read_stack(track)
          for item in tail_pointer do
            pointer << item
          end
        end

        write_stack(track, pointer)
        return parent.path
      end
    end
  end
  
  class AccessDot < Node
    def visit(track)
      path = super

      if path then
        return path
      else
        pointer = []
        pointer << elements.first.read_stack(track)

        tail = elements_by_class(AccessTail).first
        if tail then
          tail_pointer = tail.read_stack(track)
          for item in tail_pointer do
            pointer << item
          end
        end

        write_stack(track, pointer)
        return parent.path
      end
    end
  end
  
  class Identifier < Node
    def visit(track)
      write_stack(track, self.text_value)
      return parent.path
    end
  end
  
  # =============
  # = Operators =
  # =============
  
  class AssignmentOperator < Node
    include VisitOperator
  end
  
  class AdditionOperator < Node
    include VisitOperator
    
    def perform(op1, op2)
      
      if op1.class == String then
        return op1 + op2.to_s
      else
        return op1 + op2
      end
    end
  end
  
  class SubtractionOperator < Node
    include VisitOperator
    
    def perform(op1, op2)
      return op1 - op2
    end
  end
  
  class MultiplicationOperator < Node
    include VisitOperator
    
    def perform(op1, op2)
      return op1 * op2
    end
  end
  
  class DivisionOperator < Node
    include VisitOperator
    
    def perform(op1, op2)
      return op1 / op2
    end
  end
  
  class EqualityOperator < Node
    include VisitOperator
    
    def perform(op1, op2)
      return op1 == op2
    end
  end
  
  class InequalityOperator < Node
    include VisitOperator
    
    def perform(op1, op2)
      return op1 != op2
    end
  end
  
  class GreaterThanOperator < Node
    include VisitOperator
    
    def perform(op1, op2)
      return op1 > op2
    end
  end
  
  class LessThanOperator < Node
    include VisitOperator
    
    def perform(op1, op2)
      return op1 < op2
    end
  end
  
  class GreaterThanEqualOperator < Node
    include VisitOperator
    
    def perform(op1, op2)
      return op1 >= op2
    end
  end
  
  class LessThanEqualOperator < Node
    include VisitOperator
    
    def perform(op1, op2)
      return op1 <= op2
    end
  end
  
  class AndOperator < Node
    include VisitOperator
    
    def perform(op1, op2)
      return op1 && op2
    end
  end
  
  class OrOperator < Node
    include VisitOperator
    
    def perform(op1, op2)
      return op1 || op2
    end
  end
  
  class NotOperator < Node
    include VisitOperator
    
    def perform(op)
      return !op
    end
  end
  
  class UnionOperator < Node
    include VisitOperator
  end
  
  class IntersectOperator < Node
    include VisitOperator
  end
  
  class DifferenceOperator < Node
    include VisitOperator
  end
  
  class AppendOperator < Node
    include VisitOperator
  end
  
  class PrependOperator < Node
    include VisitOperator
  end
  
  class AssociatesOperator < Node
    include VisitOperator
  end
  
  class ContainsOperator < Node
    include VisitOperator
  end
  
  # ============
  # = Commands =
  # ============

  class Community < Node
    def name
      return self.elements[0].text_value
    end
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
    def name
      return self.elements[0].text_value
    end
  end
  
  class Task < Node
    def name
      return self.elements[0].text_value
    end
  end
  
  class Message < Node
    def name
      return self.elements[0].text_value
    end
  end
  
  class Properties < Node
    
  end
  
  class Property < Node
    
  end
  
  class PropertyDefaultValue < Node
    
  end
  
  class PropertyRequirementModifier < Node
    
  end
  
  class PropertyDirectionModifier < Node
    
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
    def visit(track)
      path = super
      
      identifier = elements_by_class(Identifier).first
      
      if path then
        return path
      else
          # TODO - Really consider fixing this...
          # Compute does not get called twice. parent.path is 
          # set of the containing track in continue
          identifier = identifier.read_stack(track)
          
          new_track = ::Dog::Track.new(identifier)
          new_track.control_ancestors = track.control_ancestors.clone
          new_track.control_ancestors.push(track.id)
          
          new_track.save
          
          track.state = ::Dog::Track::STATE::CALLING
          track.save
          
          return new_track
      end
    end
  end
  
  class On < Node
    def name
      name = "@"
      if self.elements_by_class(OnEach).empty? then
        name += "on:"
      else
        name += "each:"
      end
      
      name += self.elements_by_class(InClause).first.elements_by_class(Identifier).first.text_value
      
      return name
    end
  end
  
  class OnEach < Node
    
  end
  
  class OnEachCount < Node
    
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
    # SKIP
  end
  
  class DefineFunction < Node
    def name
      return self.elements[0].text_value
    end
    
    def visit(track)
      if track.function_name != self.name then
        write_stack(track, nil)
        return parent.path
      else
        path = super
        statements = elements_by_class(Statements).first
        function_on = elements_by_class(FunctionOn).first
        function_using = elements_by_class(FunctionUsing).first
        
        if path then
          if statements && path == statements.path then
            # TODO - Add variables here...
          end
          
          return path
        else
          track.state = ::Dog::Track::STATE::FINISHED
          
          if statements then
            unless track.return_value then
              track.return_value = statements.read_stack(track)
              self.write_stack(track, statements.read_stack(track))
            end
          else
            unless track.return_value then
              track.return_value = nil
              self.write_stack(track, nil)
            end
          end
          
          return nil
        end
      end
    end
  end
  
  class FunctionOn < Node
    include VisitAllChildrenReturnLast
  end
  
  class FunctionUsing < Node
    include VisitAllChildrenReturnLast
  end
  
  class FunctionOptionalParameters < Node
    def visit(track)
      path = super
      
      if path then
        return path
      else
        hash = {}
        
        for element in elements do
          element_hash = element.read_stack(track)
          for key, value in element_hash do
            hash[key] = value
          end
        end
        
        write_stack(track, hash)
        return parent.path
      end
    end
  end
  
  class FunctionOptionalParameter < Node
    def visit(track)
      path = super
      
      if path then
        return path
      else
        key = elements[0].read_stack(track)
        value = elements[1].read_stack(track)
        
        hash = {}
        hash[key] = value
        
        write_stack(track, hash)
        return parent.path
      end
    end
  end
  
  # ==================
  # = Other Commands =
  # ==================
  
  class Config < Node
    # SKIP
  end
  
  class Import < Node
    def filename
      return Shellwords::shellwords(self.elements[1].text_value).first
    end
  end
  
  class ImportAsClause < Node
    # SKIP
  end
  
  class ImportFunction < Node
    # SKIP
  end
  
  class ImportData < Node
    # SKIP
  end
  
  class ImportCommunity < Node
    # SKIP
  end
  
  class ImportTask < Node
    # SKIP
  end
  
  class ImportMessage < Node
    # SKIP
  end
  
  class ImportConfig < Node
    # SKIP
  end
  
  class Print < Node
    def visit(track)
      path = super
      
      if path then
        return path
      else
        puts elements.first.read_stack(track)
        write_stack(track, nil)
        return parent.path
      end
    end
  end
  
  class Inspect < Node
    def visit(track)
      path = super
      
      if path then
        return path
      else
        puts elements.first.read_stack(track).inspect
        write_stack(track, nil)
        return parent.path
      end
    end
  end
  
  # ======================
  # = Control Structures =
  # ======================
  
  class Repeat < Node
    
  end
  
  class If < Node
    def visit(track)
      expression = elements[0]
      true_statements = elements[1]
      false_statements = elements[2]
      
      if track.has_stack_path(expression.path) then
        expression_value = expression.read_stack(track)
        if expression_value then
          if track.has_stack_path(true_statements.path) then
            write_stack(track, true_statements.read_stack(track))
            return parent.path
          else
            return true_statements.path
          end
        else
          if false_statements then
            if track.has_stack_path(false_statements.path) then
              write_stack(track, false_statements.read_stack(track))
              return parent.path
            else
              return false_statements.path
            end
          else
            write_stack(track, nil)
            return parent.path
          end
        end
      else
        return expression.path
      end
    end
  end
  
  class ElseClause < Node
    include VisitAllChildrenReturnLast
  end
  
  class For < Node
    def visit(track)
      in_clause = elements[0]
      statements = elements[1]
      
      if(track.has_stack_path(in_clause.path)) then
        in_clause = in_clause.read_stack(track)
        
        iterator_name = in_clause[0]
        iterator_content = in_clause[1]
        
        iterator_index = track.variables["@iterator_index"]
        track.variables["iterator_index"] = iterator_index
        track.variables["@iterator_index"] += 1
        
        if statements then
          if iterator_index < iterator_content.length then
            track.variables[iterator_name] = iterator_content[iterator_index]
            return statements.path
          else
            write_stack(track, statements.read_stack(track))
            return parent.path
          end
        else
          track.variables[iterator_name] = iterator_context.last
          return parent.path
        end
      else
        track.variables["@iterator_index"] = 0
        return in_clause.path
      end
    end
  end
  
  class Break < Node
    def visit(track)
      up = self
      while up = up.parent do
        if up.class == For then
          up.write_stack(track, nil)
          return up.parent.path
        end
      end
    end
  end
  
  class Return < Node
    def visit(track)
      return_expression = elements.first
      if return_expression then
        if track.has_stack_path(return_expression.path) then
          track.state = ::Dog::Track::STATE::FINISHED
          track.return_value = return_expression.read_stack(track)
          write_stack(track, return_expression.read_stack(track))
          return nil
        else
          return return_expression.path
        end
      else
        track.state = ::Dog::Track::STATE::FINISHED
        track.return_value = nil
        write_stack(track, nil)
        return nil
      end
    end
  end
  
  class ReturnExpression < Node
    include VisitAllChildrenReturnLast
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
    def visit(track)
      path = super
      
      if path then
        return path
      else
        iterator_name = elements.first.read_stack(track)
        if elements[1] then
          iterator_content = elements[1].read_stack(track)
        else
          iterator_content = track.variables["#{iterator_name}s"]
        end
        
        write_stack(track, [iterator_name, iterator_content])
        return parent.path
      end
    end
  end
  
  class InClauseExpression < Node
    include VisitAllChildrenReturnLast
  end
  
  # =========
  # = Lists =
  # =========
  
  class KeyPaths < Node
    include VisitAllChildrenReturnAll
  end
  
  class KeyPath < Node
    include VisitAllChildrenReturnLast
  end
  
  class IdentifierAssociations < Node
    def visit(track)
      path = super
      
      if path then
        return path
      else
        hash = {}
        
        for element in elements do
          element_hash = element.read_stack(track)
          for key, value in element_hash do
            hash[key] = value
          end
        end
        
        write_stack(track, hash)
        return parent.path
      end
    end
  end
  
  class IdentifierAssociation < Node
    def visit(track)
      path = super
      
      if path then
        return path
      else
        key = elements[0].read_stack(track)
        value = elements[1].read_stack(track)
        
        hash = {}
        hash[key] = value
        
        write_stack(track, hash)
        return parent.path
      end
    end
  end
  
  class IdentifierList < Node
    include VisitAllChildrenReturnAll
  end
  
  class IdentifierListItem < Node
    include VisitAllChildrenReturnLast
  end
  
  class ArgumentList < Node
    include VisitAllChildrenReturnAll
  end
  
  class ArgumentListItem < Node
    include VisitAllChildrenReturnLast
  end
  
  # ===========
  # = Literal =
  # ===========
  
  class ArrayLiteral < Node
    include VisitAllChildrenReturnLast
  end
  
  class ArrayItems < Node
    include VisitAllChildrenReturnAll
  end
  
  class ArrayItem < Node
    include VisitAllChildrenReturnLast
  end
  
  class HashLiteral < Node
    include VisitAllChildrenReturnLast
  end
  
  class HashAssociations < Node
    def visit(track)
      path = super
      
      if path then
        return path
      else
        hash = {}
        
        for element in elements do
          element_hash = element.read_stack(track)
          for key, value in element_hash do
            hash[key] = value
          end
        end
        
        write_stack(track, hash)
        return parent.path
      end
    end
  end
  
  class HashAssociation < Node
    def visit(track)
      path = super
      
      if path then
        return path
      else
        key = elements[0].read_stack(track)
        value = elements[1].read_stack(track)
        
        hash = {}
        hash[key] = value
        
        write_stack(track, hash)
        return parent.path
      end
    end
  end
  
  class StringLiteral < Node
    def visit(track)
      write_stack(track, Shellwords::shellwords(self.text_value).first)
      return parent.path
    end
  end
  
  class IntegerLiteral < Node
    def visit(track)
      write_stack(track, self.text_value.to_i)
      return parent.path
    end
  end
  
  class FloatLiteral < Node
    def visit(track)
      write_stack(track, self.text_value.to_f)
      return parent.path
    end
  end
  
  class TrueLiteral < Node
    def visit(track)
      write_stack(track, true)
      return parent.path
    end
  end
  
  class FalseLiteral < Node
    def visit(track)
      write_stack(track, false)
      return parent.path
    end
  end

end