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
  
  module DoNotVisitMe
    def visit(track)
      write_stack(track, nil)
      return parent.path
    end
  end
  
  module VisitOnOwnTrack
    def visit(track)
      if track.function_name != self.name then
        write_stack(track, nil)
        return parent.path
      else
        path = super
        
        if path then
          return path
        else
          properties = elements_by_class(Properties).first
          
          if properties then
            properties = properties.read_stack(track)
          end
          
          track.finish
          
          track.return_value = properties
          write_stack(track, properties)
          
          return nil
        end
      end
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
        track.finish
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
  
  
  
  # ==============
  # = Structures =
  # ==============
  
  class Community < Node
    include DoNotVisitMe
    
    def name
      return self.elements[0].text_value
    end
    
    def properties
      properties = []
      community_properties = elements_by_class(CommunityProperties).first
      
      if community_properties then
        properties = community_properties.properties
      end
      
      return properties
    end
  end
  
  class CommunityProperties < Node
    include DoNotVisitMe
    
    def properties
      properties = []
      
      for element in elements do
        properties << element.property
      end
      
      return properties
    end
    
  end
  
  class CommunityProperty < Node
    include DoNotVisitMe
    
    def property
      return elements.first.property
    end
  end
  
  class CommunityPropertyAttribute < Node
    include DoNotVisitMe
    
    def property
      attribute = ::Dog::CommunityAttribute.new
      attribute.identifier = elements.first.text_value
      return attribute
    end
  end
  
  class CommunityPropertyRelationship < Node
    include DoNotVisitMe
    
    def property
      relationship = ::Dog::CommunityRelationship.new
      relationship.identifier = elements.first.text_value
      
      inverse_identifer = elements_by_class(CommunityPropertyRelationshipInverse).first
      if inverse_identifer then
        relationship.inverse_identifier = inverse_identifer.elements_by_class(Identifier).first.text_value
        
        inverse_community = inverse_identifer.elements_by_class(CommunityPropertyRelationshipInverseCommunity).first
        if inverse_community then
          relationship.inverse_community = inverse_community.elements_by_class(Identifier).first.text_value
        end
      end
      
      return relationship
    end
  end
  
  class CommunityPropertyRelationshipInverse < Node
    include DoNotVisitMe
  end
  
  class CommunityPropertyRelationshipInverseCommunity < Node
    include DoNotVisitMe
  end
  
  class Event < Node
    include VisitOnOwnTrack
    
    def name
      return self.elements[0].text_value
    end
    
    def visit(track)
      path = super
      
      if path then
        return path
      else
        task = ::Dog::RoutedEvent.new
        task.name = self.name
        task.properties = track.return_value
        
        track.return_value = task.to_hash
        write_stack(track, task.to_hash)
        
        return nil
      end
    end
  end
  
  class Task < Node
    include VisitOnOwnTrack
    
    def name
      return self.elements[0].text_value
    end
    
    def visit(track)
      path = super
      
      if path then
        return path
      else
        task = ::Dog::RoutedTask.new
        task.name = self.name
        task.properties = track.return_value
        
        track.return_value = task.to_hash
        write_stack(track, task.to_hash)
        
        return nil
      end
    end
    
  end
  
  class Message < Node
    include VisitOnOwnTrack
    
    def name
      return self.elements[0].text_value
    end
    
    def visit(track)
      path = super
      
      if path then
        return path
      else
        task = ::Dog::RoutedMessage.new
        task.name = self.name
        task.properties = track.return_value
        
        track.return_value = task.to_hash
        write_stack(track, task.to_hash)
        
        return nil
      end
    end
  end
  
  class Properties < Node
    include VisitAllChildrenReturnAll
  end
  
  class Property < Node
    def visit(track)
      path = super
      
      if path then
        return path
      else
        identifier = elements_by_class(Identifier).first
        default = elements_by_class(PropertyDefaultValue).first
        requirement = elements_by_class(PropertyRequirementModifier).first
        direction = elements_by_class(PropertyDirectionModifier).first
        
        property = ::Dog::Property.new
        property.identifier = identifier.read_stack(track)
        
        if default then
          property.value = default.read_stack(track)
        else
          property.value = nil
        end
        
        if requirement then
          property.required = requirement.read_stack(track)
        else
          property.required = false
        end
        
        # TODO - Tasks need to have a direction. I need to check for that somewhere. Probably in the ASK
        # Right now the direction is nil if it is not provided
        
        if direction then
          property.direction = direction.read_stack(track)
        else
          property.direction = nil
        end
        
        write_stack(track, property.to_hash)
        return parent.path
      end
    end
  end
  
  class PropertyDefaultValue < Node
    include VisitAllChildrenReturnLast
  end
  
  class PropertyRequirementModifier < Node
    def visit(track)
      if self.text_value.strip == "required" then
        write_stack(track, true)
      else
        write_stack(track, false)
      end
      
      return parent.path
    end
  end
  
  class PropertyDirectionModifier < Node
    def visit(track)
      write_stack(track, self.text_value.strip)
      return parent.path
    end
  end
  
  
  
  # ============
  # = Commands =
  # ============
  
  class Allow < Node
    
  end
  
  class AllowModifier < Node
    
  end
  
  class AllowProfile < Node
    
  end
  
  class Listen < Node
    def visit(track)
      path = super
      
      if path then
        return path
      else
        # TODO - I need to handle the routing... Probably after I box the values
        listen_for_clause = elements_by_class(ListenForClause).first
        hashed_event = listen_for_clause.read_stack(track)
        
        event = ::Dog::RoutedEvent.from_hash(hashed_event)
        event.track_id = track.id
        event.routing = nil # TODO
        event.created_at = Time.now.utc
        event.save
        
        event = {
          "dog_type" => "event",
          "id" => event.id
        }
        
        track.has_listen = true
        track.variables[listen_for_clause.identifier] = event
        write_stack(track, event)
        
        return parent.path
      end
    end
  end 
  
  class ListenToClause < Node
    include VisitAllChildrenReturnLast
  end
  
  class ListenForClause < Node
    def identifier
      elements_by_class(Identifier).first.text_value
    end
    
    def visit(track)
      path = super
      
      if path then
        return path
      else
        event_name = nil
        
        identifier = elements_by_class(Identifier).first.read_stack(track)
        listen_of_clause = elements_by_class(ListenOfClause).first
        
        if listen_of_clause then
          event_name = listen_of_clause.read_stack(track)
        else
          event_name = identifier
          event_name = event_name.chop
        end
        
        new_track = ::Dog::Track.new(event_name)
        new_track.control_ancestors = track.control_ancestors.clone
        new_track.control_ancestors.push(track.id)
        new_track.save
        
        track.state = ::Dog::Track::STATE::CALLING
        track.save
        
        return new_track
      end
    end
  end
  
  class ListenOfClause < Node
    include VisitAllChildrenReturnLast
  end
  
  class Ask < Node
    def visit(track)
      path = super
      
      if path then
        return path
      else
        # TODO - I need to handle the routing... Probably after I box the values
        ask_to_clause = elements_by_class(AskToClause).first
        ask_to_clause = ask_to_clause.read_stack(track)
        
        on_clause = elements_by_class(OnClause).first
        using_clause = elements_by_class(UsingClause).first
        
        task = ::Dog::RoutedTask.from_hash(ask_to_clause)
        task.track_id = track.id
        task.routing = nil # TODO
        task.created_at = Time.now.utc
        task.replication = elements_by_class(AskCount).first.read_stack(track) rescue 1
        task.duplication = 1
        
        if using_clause then
          using_clause = using_clause.read_stack(track)
          
          for key, value in using_clause do
            for property in task.properties do
              if property.identifier == key then
                property.value = value
              end
            end
          end
        end
        
        if on_clause then
          on_clause = on_clause.read_stack(track)
          
          if on_clause.kind_of? Hash then
            for key, value in on_clause do
              for property in task.properties do
                if property.identifier == key then
                  property.value = value
                end
              end
            end
          else
            index = 0
            for property in task.properties do
              if property.required then
                property.value = on_clause[index]
                index += 1
              end
            end
          end
        end
        
        for property in task.properties do
          if property.required && property.value.nil? then
            raise "A required property (#{property.identifier}) was not set for task (#{task.name})."
          end
        end
        
        task.save
        
        write_stack(track, {
          "dog_type" => "task",
          "id" => task.id
        })
        
        return parent.path
      end
    end
  end
  
  class AskCount < Node
    include VisitAllChildrenReturnLast
  end
  
  class AskToClause < Node
    def visit(track)
      path = super
      
      if path then
        return path
      else
        identifier = elements_by_class(Identifier).first
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
  
  class Notify < Node
    def visit(track)
      path = super
      
      if path then
        return path
      else
        # TODO - I need to handle the routing... Probably after I box the values
        notify_of_clause = elements_by_class(NotifyOfClause).first
        notify_of_clause = notify_of_clause.read_stack(track)
        
        using_clause = elements_by_class(UsingClause).first
        
        message = ::Dog::RoutedMessage.from_hash(notify_of_clause)
        message.track_id = track.id
        message.routing = nil # TODO
        message.created_at = Time.now.utc
        
        if using_clause then
          using_clause = using_clause.read_stack(track)
          
          for key, value in using_clause do
            for property in message.properties do
              if property.identifier == key then
                property.value = value
              end
            end
          end
        end
        
        message.save
        
        write_stack(track, {
          "dog_type" => "message",
          "id" => message.id
        })
        
        return parent.path
      end
    end
  end
  
  class NotifyOfClause < Node
    def visit(track)
      path = super
      
      if path then
        return path
      else
        identifier = elements_by_class(Identifier).first
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
  
  class Reply < Node
    
  end
  
  class ReplyWithClause < Node
    
  end
  
  class Compute < Node
    def visit(track)
      path = super
      
      if path then
        return path
      else
        identifier = elements_by_class(Identifier).first
        mandatory_args = elements_by_class(OnClause).first
        optional_args = elements_by_class(UsingClause).first
        
        # TODO - Really consider fixing this...
        # Compute does not get called twice. parent.path is 
        # set of the containing track in continue
        identifier = identifier.read_stack(track)
        
        new_track = ::Dog::Track.new(identifier)
        new_track.control_ancestors = track.control_ancestors.clone
        new_track.control_ancestors.push(track.id)
        
        if mandatory_args then
          new_track.mandatory_arguments = mandatory_args.read_stack(track)
        end
        
        if optional_args then
          new_track.optional_arguments = optional_args.read_stack(track)
        end
        
        new_track.save
        
        track.state = ::Dog::Track::STATE::CALLING
        track.save
        
        return new_track
      end
    end
  end
  
  class On < Node
    
    # TODO - This is not the correct name. I need to make sure that this is the full path name, especially when I am creating a new track in nodes like COMPUTE, ASK, MESSAGE, etc.
    # Name is NOT the actual symbol name to look up from the compiled bite code...
    
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
    
    def visit(track)
      if track.function_name != self.name then
        on_each = elements_by_class(OnEach).first
        in_clause = elements_by_class(InClause).first
        
        if on_each && !track.has_stack_path(on_each.path) then
          return on_each.path
        end
        
        if in_clause && !track.has_stack_path(in_clause.path) then
          return in_clause.path
        end
        
        in_clause = in_clause.read_stack(track)
        variable_name = in_clause[0]
        stream_object_id = in_clause[1]["id"]
        
        stream_object = ::Dog::StreamObject.find_by_id(stream_object_id)
        stream_object.handler = self.name
        stream_object.handler_argument = variable_name
        stream_object.save
        
        self.write_stack(track, nil)
        return parent.path
      else
        statements = elements_by_class(Statements).first
        
        if statements && !track.has_stack_path(statements.path) then 
          return statements.path
        else
          return nil
        end
      end
    end
  end
  
  class OnEach < Node
    def visit(track)
      on_each_count = elements_by_class(OnEachCount).first
      if on_each_count then
        if track.has_stack_path(on_each_count) then
          write_stack(track, on_each_count.read_stack(track))
          return parent.path
        else
          return on_each_count.path
        end
      else
        write_stack(track, 1)
        return parent.path
      end
    end
  end
  
  class OnEachCount < Node
    include VisitAllChildrenReturnLast
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

            if function_using then
              function_using = function_using.read_stack(track)

              for key, value in function_using do
                track.variables[key] = value
              end

              if track.optional_arguments
                for key, value in track.optional_arguments do
                  if function_using.include?(key) then
                    track.variables[key] = value
                  else
                    # TODO - Raise error?
                    raise "Error calling function: 1"
                  end
                end
              end
            end

            if function_on then
              function_on = function_on.read_stack(track)
              if track.mandatory_arguments then
                if track.mandatory_arguments.kind_of? Hash then
                  for key, value in track.mandatory_arguments do
                    if function_on.include? key then
                      track.variables[key] = value
                    else
                      # TODO - Raise error?
                      raise "Error calling function: 2"
                    end
                  end
                else
                  if track.mandatory_arguments.length == function_on.length then
                    track.mandatory_arguments.each_index do |index|
                      track.variables[function_on[index]] = track.mandatory_arguments[index]
                    end
                  else
                    # TODO - Raise error?
                    raise "Error calling function: 3"
                  end
                end
              end
              
              for value in function_on do
                unless track.variables.include?(value) then
                  raise "A mandatory argument was not passed to this function!"
                end
              end
              
            end
          end
          
          return path
        else
          track.finish
          
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
          track.finish
          track.return_value = return_expression.read_stack(track)
          write_stack(track, return_expression.read_stack(track))
          return nil
        else
          return return_expression.path
        end
      else
        track.finish
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
    include VisitAllChildrenReturnLast
  end
  
  class UsingClauseContent < Node
    include VisitAllChildrenReturnLast
  end
  
  class OnClause < Node
    include VisitAllChildrenReturnLast
  end
  
  class OnClauseContent < Node
    include VisitAllChildrenReturnLast
  end
  
  class ViaClause < Node
    include VisitAllChildrenReturnLast
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
      write_stack(track, self.text_value.to_f)
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