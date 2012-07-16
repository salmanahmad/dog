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
    
    attr_accessor :path
    
    def compute_paths_of_descendants_for_array(array, current = [])
      array.each_index do |key|
        value = array[key]
        current_path = current.clone.push(key)
        
        if value.kind_of? Array then
          compute_paths_of_descendants_for_array(value, current_path)
        elsif value.kind_of? Hash then
          compute_paths_of_descendants_for_hash(value, current_path)
        elsif value.kind_of? Node then
          value.compute_paths_of_descendants(current_path)
        end
      end
    end
    
    def compute_paths_of_descendants_for_hash(hash, current = [])
      for key, value in hash do
        current_path = current.clone.push(key)
        
        if value.kind_of? Array then
          compute_paths_of_descendants_for_array(value, current_path)
        elsif value.kind_of? Hash then
          compute_paths_of_descendants_for_hash(value, current_path)
        elsif value.kind_of? Node then
          value.compute_paths_of_descendants(current_path)
        end
      end
    end
    
    def compute_paths_of_descendants(current = [])
      self.path = current
      
      for attribute in self.attributes do
        value = self.send(attribute.intern)
        current_path = current.clone.push(attribute.to_s)
        
        if value.kind_of? Array then
          compute_paths_of_descendants_for_array(value, current_path)
        elsif value.kind_of? Hash then
          compute_paths_of_descendants_for_hash(value, current_path)
        elsif value.kind_of? Node then
          value.compute_paths_of_descendants(current_path)
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
        "path" => self.path
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
      
      for key, value in hash to
        if self.attributes.include? key.intern then
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
    end
  end
  
  class Nodes < Node
    attribute :nodes
  end
  
  class Access < Node
    attribute :sequence
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
  
  class Perform < Node
    
  end
  
  class Break < Node
    
  end
  
  class Return < Node
    attribute :expression
  end
  
  class Print < Node
    attribute :expression
  end
  
  class Inspect < Node
    attribute :expression
  end
  
  
  class LiteralNode < Node
    attribute :value
  end
  
  class StructureLiteral < LiteralNode
    attribute :type
  end
  
  class StringLiteral < LiteralNode
    
  end
  
  class NumberLiteral < LiteralNode
    
  end
  
  class TrueLiteral < LiteralNode
    
  end
  
  class FalseLiteral < LiteralNode
    
  end
  
  class NullLiteral < LiteralNode
    
  end
  
end