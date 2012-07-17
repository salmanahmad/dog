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
    
    def line
      1 + self.input.slice(0, self.interval.begin).count("\n")
    end
  end
  
  class Node
    def self.attr_accessor(*vars)
      super(*vars)
    end
    
    def self.attribute(*vars)
      @attributes ||= []
      @attributes.concat vars
      self.attr_accessor(*vars)
    end
    
    def self.attributes
      (superclass.attributes || [] rescue []) | (@attributes || [])
    end
    
    def attributes
      self.class.attributes
    end
    
    def [](key)
      if self.attributes.include? key.intern then
        self.send(key.intern)
      end
    end
    
    attr_accessor :line
    attr_accessor :filename
    
    attr_accessor :path
    attr_accessor :parent
    
    # TODO - I have to consider the impact to path with packages
    
    def compute_paths_of_descendants_for_array(array, current = [], parent)
      array.each_index do |key|
        value = array[key]
        current_path = current.clone.push(key)
        
        if value.kind_of? Array then
          compute_paths_of_descendants_for_array(value, current_path, parent)
        elsif value.kind_of? Hash then
          compute_paths_of_descendants_for_hash(value, current_path, parent)
        elsif value.kind_of? Node then
          value.compute_paths_of_descendants(current_path, parent)
        end
      end
    end
    
    def compute_paths_of_descendants_for_hash(hash, current = [], parent)
      for key, value in hash do
        current_path = current.clone.push(key)
        
        if value.kind_of? Array then
          compute_paths_of_descendants_for_array(value, current_path, parent)
        elsif value.kind_of? Hash then
          compute_paths_of_descendants_for_hash(value, current_path, parent)
        elsif value.kind_of? Node then
          value.compute_paths_of_descendants(current_path, parent)
        end
      end
    end
    
    def compute_paths_of_descendants(current = [], parent = nil)
      self.path = current
      self.parent = parent
      
      for attribute in self.attributes do
        value = self.send(attribute.intern)
        current_path = current.clone.push(attribute.to_s)
        
        if value.kind_of? Array then
          compute_paths_of_descendants_for_array(value, current_path, self)
        elsif value.kind_of? Hash then
          compute_paths_of_descendants_for_hash(value, current_path, self)
        elsif value.kind_of? Node then
          value.compute_paths_of_descendants(current_path, self)
        end
      end
    end
    
    def self.each_descendant(node, &block)
      if node.kind_of? Array then
        for item in node do
          each_descendant(item, &block)
        end
      elsif node.kind_of? Hash then
        for key, value in node do
          each_descendant(value, &block)
        end
      elsif node.kind_of? Node then
        yield node
        
        for attribute in node.attributes do
          each_descendant(node.send(attribute.intern), &block)
        end
      end
    end
    
    def visit(track)
      # This is used by the runtime to implement the execution.
    end
    
    def to_hash_for_array(array)
      array.map! do |item|
        if item.kind_of? Array
          item = to_hash_for_array(item)
        elsif item.kind_of? Hash
          item = {
            "type" => "Hash",
            "value" => to_hash_for_hash(item)
          }
        elsif item.kind_of? Node
          item = {
            "type" => "Node",
            "value" => item.to_hash
          }
        end
        
        item
      end
      
      return array
    end
    
    def to_hash_for_hash(hash)
      for key, value in hash do
        if value.kind_of? Array then
          hash[key] = to_hash_for_array(value)
        elsif value.kind_of? Hash then
          hash[key] = {
            "type" => "Hash",
            "value" => to_hash_for_hash(value)
          }
        elsif value.kind_of? Node then
          hash[key] = {
            "type" => "Node",
            "value" => value.to_hash
          }
        end
      end
      
      return hash
    end
    
    def to_hash
      # This method is used to produced a serialized version of the AST. It will be called
      # inconjunction with to_json to produce to persist the bite code to disk.
      hash = {
        "class" => self.class.name,
        "path" => self.path,
        "line" => self.line,
        "filename" => self.filename
      }
      
      for attribute in self.attributes do
        # I am boxing all of the values so I can easily de-deserialize them
        value = self.send(attribute.intern)
        
        if value.kind_of? Array
          value = to_hash_for_array(value)
        elsif value.kind_of? Hash
          value = {
            "type" => "Hash",
            "value" => to_hash_for_hash(value)
          }          
        elsif value.kind_of? Node
          value = {
            "type" => "Node",
            "value" => value.to_hash
          }
        end
        
        hash[attribute.to_s] = value
      end
      
      return hash
    end
    
    def self.from_hash_for_array(array)
      array.map! do |item|
        if item.kind_of? Array
          item = self.from_hash_for_array(item)
        elsif item.kind_of? Hash
          if item["type"] == "Node"
            item = Node.from_hash(item["value"])
          else
            item = self.from_hash_for_hash(item["value"])
          end
        end
        
        item
      end
      
      return array
    end
    
    def self.from_hash_for_hash(hash)
      for key, value in hash do
        if value.kind_of? Array
          hash[key] = self.from_hash_for_array(value)
        elsif value.kind_of? Hash
          if value["type"] == "Node" then
            hash[key] = Node.from_hash(value["value"])
          else
            hash[key] = self.from_hash_for_hash(value["value"])
          end
        end
      end
      
      return hash
    end
    
    def self.from_hash(hash)
      klass = hash["class"] || self.class.name
      klass = Kernel::qualified_const_get(klass)
      
      node = klass.new
      node.path = hash["path"]
      node.line = hash["line"]
      node.filename = hash["filename"]
      
      for key, value in hash do
        
        if node.attributes.include? key.intern then
          if value.kind_of? Array
            value = self.from_hash_for_array(value)
          elsif value.kind_of? Hash
            if value["type"] == "Node"
              value = Node.from_hash(value["value"])
            else
              value = self.from_hash_for_hash(value["value"])
            end
          end
            
          node.send("#{key.to_s}=".intern, value)
        end
      end
      
      return node
    end
  end
  
  class Nodes < Node
    attribute :nodes
    
    def visit(track)
      
      for node in self.nodes do
        unless track.has_visited?(node) then
          track.should_visit(node)
          return
        end
      end
      
      if self.nodes && self.nodes.last then
        value = track.read_stack(self.nodes.last.path)
        track.write_stack(self.path, value)
      end
      
      track.should_visit(self.parent)
    end
  end
  
  class Access < Node
    attribute :sequence
    
    def visit(track)
      if self.sequence then
        for item in self.sequence do
          if item.kind_of? Node then
            unless track.has_visited? item then
              track.should_visit(item)
              return
            end
          end
        end
        
        access_path = []
        for item in self.sequence do
          if item.kind_of? Node then
            result = track.read_stack(item.path)
            access_path << result
          else
            access_path << item
          end
        end
        
        first = true
        value = nil
        
        for item in access_path do
          if first then
            first = false
            
            if item.kind_of? ::Dog::Value then
              value = item
            else
              value = track.variables[item]
            end            
          else
            if item.kind_of? ::Dog::Value then
              # TODO - I should box string and numeric keys...right?
            else
              
            end
          end  
        end
        
        track.write_stack(self.path, value)
        track.should_visit(self.parent)
      else
        track.write_stack(self.path, ::Dog::Value.null_value)
        track.should_visit(self.parent)
      end
    end
  end
  
  class Assignment < Node
    attribute :expression
    attribute :sequence
  end
  
  class FunctionDefinition < Node
    attribute :name
    attribute :target
    attribute :mandatory_arguments
    attribute :optional_arguments
    attribute :body
  end
  
  class OnEachDefinition < Node
    attribute :name
    attribute :variable
    attribute :collection
    attribute :body
  end
  
  class OperatorInfixCall < Node
    attribute :operator
    attribute :arg1
    attribute :arg2
    
    def visit(track)
      
      unless track.has_visited?(self.arg1) then
        track.should_visit(self.arg1)
        return
      end
      
      unless track.has_visited?(self.arg2) then
        track.should_visit(self.arg2)
        return
      end
      
      arg1_value = track.read_stack(self.arg1.path).value
      arg2_value = track.read_stack(self.arg2.path).value
      
      result = arg1_value.send(self.operator.intern, arg2_value)
      
      track.write_stack(self.path, ::Dog::Value.new("number", result))
      track.should_visit(self.parent)
    end
  end
  
  class OperatorPrefixCall < Node
    attribute :operator
    attribute :arg
  end
  
  class FunctionCall < Node
    attribute :function_name
    attribute :mandatory_arguments
    attribute :optional_arguments
  end
  
  class FunctionAsyncCall < Node
    attribute :target
    attribute :function_name
    attribute :mandatory_arguments
    attribute :optional_arguments
    attribute :via
  end
  
  class StructureDefinition < Node
    attribute :name
    attribute :properties
  end
  
  class StructureDefinitionProperty < Node
    attribute :type
    attribute :name
    attribute :default
  end
  
  class CollectionDefinition < Node
    attribute :name
    attribute :structure_name
  end
  
  class CommunityDefinition < Node
    attribute :name
    attribute :properties
  end
  
  class Listen < Node
    attribute :target
    attribute :variable
    attribute :variable_type
    attribute :via
  end
  
  class Notify < Node
    attribute :target
    attribute :message
    attribute :via
  end
  
  class If < Node
    attribute :conditions
  end
  
  class While < Node
    attribute :condition
    attribute :statements
  end
  
  class For < Node
    attribute :variable
    attribute :collection
    attribute :statements
  end
  
  class Import < Node
    attribute :path
  end
  
  class Perform < Node
    
  end
  
  class Break < Node
    
  end
  
  class Return < Node
    attribute :expression
  end
  
  class Print < Node
    attribute :expression
    
    def visit(track)
      value = ""
      
      if self.expression then
        if track.has_visited?(self.expression) then
          value = track.read_stack(self.expression.path).value
        else
          track.should_visit(self.expression)
          return
        end
      end
      
      puts value
      
      track.write_stack(self.path, ::Dog::Value.null_value)
      track.should_visit(self.parent)
    end
  end
  
  class Inspect < Node
    attribute :expression
    
    def visit(track)
      value = ""
      
      if self.expression then
        if track.has_visited?(self.expression) then
          value = track.read_stack(self.expression.path).value
        else
          track.should_visit(self.expression)
          return
        end
      end
      
      puts value.inspect
      
      track.write_stack(self.path, ::Dog::Value.null_value)
      track.should_visit(self.parent)
    end
  end
  
  
  class LiteralNode < Node
    attribute :value
  end
  
  class StructureLiteral < LiteralNode
    attribute :type
  end
  
  class StringLiteral < LiteralNode
    def visit(track)
      track.write_stack(self.path, ::Dog::Value.string_value(value))
      track.should_visit(self.parent)
    end
  end
  
  class NumberLiteral < LiteralNode
    def visit(track)
      track.write_stack(self.path, ::Dog::Value.number_value(value))
      track.should_visit(self.parent)
    end
  end
  
  class TrueLiteral < LiteralNode
    def visit(track)
      track.write_stack(self.path, ::Dog::Value.true_value)
      track.should_visit(self.parent)
    end
    
  end
  
  class FalseLiteral < LiteralNode
    def visit(track)
      track.write_stack(self.path, ::Dog::Value.false_value)
      track.should_visit(self.parent)
    end
    
  end
  
  class NullLiteral < LiteralNode
    def visit(track)
      track.write_stack(self.path, ::Dog::Value.null_value)
      track.should_visit(self.parent)
    end
    
  end
  
end