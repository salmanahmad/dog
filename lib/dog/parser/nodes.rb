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
      @attributes_cache ||= (superclass.attributes || [] rescue []) | (@attributes || [])
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
              value = track.read_variable(item)
            end            
          else
            if value.nil? || value.type == "null" then
              raise "Null pointer excep --- Just kidding. I just couldn't resolve the attribute #{item} on line #{self.line}."
            end
            
            begin
              if item.kind_of? ::Dog::Value then
                if item.type == "number" then
                  value = value.value["n:#{item.value}"]
                elsif item.type == "string" then
                  value = value.value["s:#{item.value}"]
                else
                  raise
                end
              else
                value = value.value["s:#{item}"]
              end
            rescue
              raise "I could not find attribute #{item} inside of the value #{value} on line #{self.line}."
            end
            
          end  
        end
        
        # This is an edge case in case the value was not found at all
        value = ::Dog::Value.null_value if value.nil? 
        
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
    
    def visit(track)
      
      expression_value = ::Dog::Value.null_value
      sequence_value = []
      
      if self.expression then
        unless track.has_visited?(self.expression) then
          track.should_visit(self.expression)
          return
        end
        
        expression_value = track.read_stack(self.expression.path)
      end
      
      if self.sequence then
        for item in self.sequence do
          if item.kind_of? Node then
            unless track.has_visited? item then
              track.should_visit(item)
              return
            end
          end
        end
        
        sequence_value = []
        for item in self.sequence do
          if item.kind_of? Node then
            result = track.read_stack(item.path)
            sequence_value << result
          else
            sequence_value << item
          end
        end
      end
      
      first = true
      pointer = nil
      variable = nil
      
      for item in sequence_value do
        if first then
          first = false
          
          if item.kind_of? ::Dog::Value then
            raise "Void assignment expression"
          else
            variable = track.read_variable(item)
            pointer = variable
          end
          
        else
                    
          begin
            path = ""
            
            if item.kind_of? ::Dog::Value then
              if item.type == "number" then
                path = "n:#{item.value}"
              elsif item.type == "string" then
                path = "s:#{item.value}"
              else
                raise
              end
            else
              path = "s:#{item}"
            end
            
            unless pointer.primitive?
              pointer.value[path] ||= ::Dog::Value.null_value
            end
              
            pointer = pointer.value[path]
          rescue Exception => e
            raise e
            raise "I could not perform the assignment on line: #{self.line}"
          end
          
        end
      end
      
      pointer.type = expression_value.type
      pointer.value = expression_value.value
      
      track.write_variable(sequence_value.first, variable)
      
      track.write_stack(self.path, expression_value)
      track.should_visit(self.parent)
    end
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
      
      arg1_value = track.read_stack(self.arg1.path)
      arg2_value = track.read_stack(self.arg2.path)
      
      result = nil
      
      if arg1_value.primitive? && arg2_value.primitive? then
        begin
          result = arg1_value.value.send(self.operator.intern, arg2_value.value)
          if result.kind_of? String then
            result = ::Dog::Value.string_value(result)
          elsif result.kind_of? Numeric then
            result = ::Dog::Value.number_value(result)
          elsif result.kind_of? TrueClass
            result = ::Dog::Value.true_value
          elsif result.kind_of? FalseClass then
            result = ::Dog::Value.false_value
          else
            result = ::Dog::Value.null_value
          end
        rescue
          result = ::Dog::Value.null_value
        end
      end
      
      track.write_stack(self.path, result)
      track.should_visit(self.parent)
    end
  end
  
  class OperatorPrefixCall < Node
    attribute :operator
    attribute :arg
    
    def visit(track)
      if track.has_visited? self.arg then
        if self.operator == "NOT" then
          value = track.read_stack(self.arg.path)
          if value.type == "null" || (value.type == "boolean" && value.value == false) then
            track.write_stack(self.path, ::Dog::Value.true_value)
          else
            track.write_stack(self.path, ::Dog::Value.false_value)
          end
        else
          raise "Unknown unary operator on line: #{self.line}"
        end
      else
        track.should_visit(self.arg)
        return
      end
    end
  end
  
  class FunctionDefinition < Node
    attribute :name
    attribute :target
    attribute :mandatory_arguments
    attribute :optional_arguments
    attribute :body
    
    def visit(track)
      if track.function_name != self.name then
        track.write_stack(self.path, ::Dog::Value.null_value)
        track.should_visit(self.parent)
        return
      else
        if self.body.nil? then
          track.finish
          track.write_return_value(::Dog::Value.null_value)
          return
        end
        
        if track.has_visited? self.body then
          track.finish
          track.write_return_value(track.read_stack(self.body.path))
          return
        else
          
          state = track.read_stack(self.path.clone << "@state")
          
          if state.nil? then
            if self.mandatory_arguments then
              self.mandatory_arguments.each_index do |index|
                arg = mandatory_arguments[index]
                value = nil
              
                if track.mandatory_arguments.kind_of? Array then
                  value = track.mandatory_arguments[index]
                else
                  value = track.mandatory_arguments[arg]
                end
              
                if value.nil? then
                  raise "Error: Did not recieve a mandatory argument on line: #{self.line}"
                end
                
                value = ::Dog::Value.from_hash(value)
                track.write_variable(arg, value);
              end
            end
            
            state = ::Dog::Value.string_value("mandatory_arguments")
            track.write_stack(self.path.clone << "@state", state)
          end
          
          if state.value == "mandatory_arguments" then
            if self.optional_arguments then
              for key, value in track.optional_arguments do
                if self.optional_arguments.include? key then
                  value = ::Dog::Value.from_hash(value)
                  track.write_variable(key, value);
                end
              end
            end
            
            state = ::Dog::Value.string_value("used_passed_optional_arguments")
            track.write_stack(self.path.clone << "@state", state)
          end
          
          if state.value == "used_passed_optional_arguments" then
            if self.optional_arguments then
              for key, value in self.optional_arguments do
                if track.variables[key].nil? then
                  unless track.has_visited? value then
                    track.should_visit(value)
                    return
                  else
                    track.write_variable(key, track.read_stack(value.path))
                  end
                end
              end
            end
            
            state = ::Dog::Value.string_value("done")
            track.write_stack(self.path.clone << "@state", state)
          end
          
          track.should_visit(self.body)
          return
        end
      end
    end
    
  end
  
  class OnEachDefinition < Node
    attribute :name
    attribute :variable
    attribute :collection
    attribute :body
    
    def visit(track)
      if track.function_name != self.name then
        track.write_stack(self.path, ::Dog::Value.null_value)
        track.should_visit(self.parent)
        return
      else
        if self.body.nil? then
          track.finish
          track.write_return_value(::Dog::Value.null_value)
          return
        end
        
        if track.has_visited? self.body then
          track.finish
          track.write_return_value(track.read_stack(self.body.path))
          return
        else
          track.should_visit(self.body)
          return
        end  
      end
    end
    
  end
  
  class FunctionCall < Node
    attribute :function_name
    attribute :mandatory_arguments
    attribute :optional_arguments
    
    def visit(track)
      
      passed_mandatory_arguments = {}
      
      if self.mandatory_arguments then
        
        if self.mandatory_arguments.kind_of? Array then
          passed_mandatory_arguments = []
          
          for arg in self.mandatory_arguments do
            unless track.has_visited? arg then
              track.should_visit(arg)
              return
            end
            
            passed_mandatory_arguments << track.read_stack(arg.path).to_hash
          end
        else
          passed_mandatory_arguments = {}
          
          for key, arg in self.mandatory_arguments do
            unless track.has_visited? arg then
              track.should_visit(arg)
              return
            end
            
            passed_mandatory_arguments[key] = track.read_stack(arg.path).to_hash
          end
        end
      end
      
      passed_optional_arguments = {}
      
      if self.optional_arguments then
        for key, arg in self.optional_arguments do
          unless track.has_visited? arg then
            track.should_visit(arg)
            return
          end
          
          passed_optional_arguments[key] = track.read_stack(arg.path).to_hash
        end
      end
      
      # TODO - I need to save here so that I can get the track.id. I may want to
      # optimize this in the future so that I can reduce the overhead of a function call
      track.save
      
      function = ::Dog::Track.new(self.function_name)
      function.control_ancestors = track.control_ancestors.clone
      function.control_ancestors.push(track.id)
      
      function.mandatory_arguments = passed_mandatory_arguments
      function.optional_arguments = passed_optional_arguments
      
      track.state = ::Dog::Track::STATE::CALLING
      return function
    end
  end
  
  class FunctionAsyncCall < Node
    attribute :target
    attribute :function_name
    attribute :mandatory_arguments
    attribute :optional_arguments
    attribute :via
  end
  
  # TODO - I need to handle type safety with structures and functions
  
  class StructureDefinition < Node
    attribute :name
    attribute :properties
    
    def visit(track)
      if track.function_name != self.name then
        track.write_stack(self.path, ::Dog::Value.null_value)
        track.should_visit(self.parent)
        return
      else
        structure = ::Dog::Value.new(self.name, {})
        
        if self.properties then
          for property in self.properties do
            unless track.has_visited? property then
              track.should_visit(property)
              return
            end
          end
          
          for property in self.properties do
            default = track.read_stack(property.path)
            key = property.name
            
            if key.kind_of? Numeric then
              key = "n:#{key}"
            else
              key = "s:#{key}"
            end
            
            structure.value[key] = default
          end
        end
        
        track.finish
        track.write_return_value(structure)
        return
      end
    end
  end
  
  class StructureDefinitionProperty < Node
    attribute :type
    attribute :name
    attribute :default
    
    def visit(track)
      if self.default then
        if track.has_visited? self.default then
          track.write_stack(self.path, track.read_stack(self.default.path))
          track.should_visit(self.parent)
          return                    
        else
          track.should_visit(self.default)
          return
        end
      else
        track.write_stack(self.path, ::Dog::Value.null_value)
        track.should_visit(self.parent)
        return
      end
    end
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
    
    def visit(track)
      
      if self.target then
        unless track.has_visited?(self.target) then
          track.should_visit(self.target)
          return
        end
      end
      
      structure_type = self.variable_type
      properties = []
      
      if structure_type.nil? then
        # TODO - Validate this..
        structure_type = self.variable.chop
        
        # TODO - Do I deal with defaults before or after? I guess that I
        # really should do it after
        
        # TOOD - I have to handle the nested and fully qualified names
        path = ::Dog::Runtime.bite_code["symbols"][structure_type]
        if path then
          
          path = path.clone
          path.shift
          
          node = ::Dog::Runtime.node_at_path_for_filename(path, ::Dog::Runtime.bite_code["main_filename"])
          for p in node.properties do
            p2 = ::Dog::Property.new
            p2.identifier = p.name
            p2.direction = "input"
            properties << p2
          end
        end
      end
      
      
      
      event = ::Dog::RoutedEvent.new
      event.name = structure_type
      event.properties = properties
      event.track_id = track.id
      event.routing = nil # TODO
      event.created_at = Time.now.utc
      event.save
      
      track.has_listen = true
      track.should_visit(self.parent)
      track.write_stack(self.path, ::Dog::Value.null_value)
      track.write_variable(self.variable, ::Dog::Value.new("event", {
        "s:id" => ::Dog::Value.string_value(event.id.to_s)
      }));
      
      return
    end
  end
  
  class Notify < Node
    attribute :target
    attribute :message
    attribute :via
  end
  
  class If < Node
    attribute :conditions
    
    def visit(track)
      for condition in self.conditions do
        if condition.first then
          # if or else if
          if track.has_visited?(condition.first) then
            value = track.read_stack(condition.first.path)
            
            unless value.type == "null" || (value.type == "boolean" && value.value == false) then
              if condition.last then
                if track.has_visited?(condition.last) then
                  value = track.read_stack(condition.last.path)
                  track.write_stack(self.path, value)
                  track.should_visit(self.parent)
                  return
                else
                  track.should_visit(condition.last)
                  return
                end
              else
                track.write_stack(self.path, ::Dog::Value.null_value)
                track.should_visit(self.parent)
                return
              end
            end
          else
            track.should_visit(condition.first)
            return            
          end
        else
          # else statement
          if condition.last then
            if track.has_visited?(condition.last) then
              value = track.read_stack(condition.last.path)
              track.write_stack(self.path, value)
              track.should_visit(self.parent)
              return
            else
              track.should_visit(condition.last)
              return
            end
          else
            track.write_stack(self.path, ::Dog::Value.null_value)
            track.should_visit(self.parent)
            return
          end
        end
      end
    end
  end
  
  class While < Node
    attribute :condition
    attribute :statements
    
    def visit(track)
      
      
      state = track.read_stack(self.path.clone << "@state")
            
      if state == nil then
        # Never visited here before. Going to evaluate the condition
        track.write_stack(self.path.clone << "@state", ::Dog::Value.string_value("condition"))
        
        track.should_visit(self.condition)
        return
      elsif state.value == "condition"
        value = track.read_stack(self.condition.path)
        
        unless value.type == "null" || (value.type == "boolean" && value.value == false) then
          track.write_stack(self.path.clone << "@state", ::Dog::Value.string_value("statements"))

          track.should_visit(self.statements)
          return
        else
          track.write_stack(self.path, ::Dog::Value.null_value)
          track.should_visit(self.parent)
          return
        end
      elsif state.value == "statements"
        track.write_stack(self.path.clone << "@state", ::Dog::Value.string_value("condition2"))
        
        track.clear_stack(self.condition.path)
        track.should_visit(self.condition)
        return
      elsif state.value == "condition2"
        value = track.read_stack(self.condition.path)
        
        unless value.type == "null" || (value.type == "boolean" && value.value == false) then
          track.write_stack(self.path.clone << "@state", ::Dog::Value.string_value("statements"))
          
          track.clear_stack(self.statements.path)
          track.should_visit(self.statements)
          return
        else
          track.write_stack(self.path, track.read_stack(self.statements.path))
          track.should_visit(self.parent)
          return
        end
      end
      
    end
  end
  
  class For < Node
    attribute :variable
    attribute :collection
    attribute :statements
    
    def visit(track)
      # TODO - The for loop should pass the key as well as the value to the block.
      # This will involve us de-serializing the "n:..." and "s:..." syntax.
      
      unless track.has_visited? self.collection then
        track.should_visit(self.collection)
        return
      end
      
      collection = track.read_stack(self.collection.path)
      
      if collection.primitive? then
        raise "You cannot iterate over a non-collection. Line: #{self.line}"
      end
      
      index = track.read_stack(self.path.clone << "@index")
      index = ::Dog::Value.number_value(0) if index == nil
      
      keys = collection.value.keys
      
      if index.value == keys.length then
        track.write_stack(self.path, track.read_stack(self.statements.path))
        track.should_visit(self.parent)
        return
      else
        key = keys[index.value]
        value = collection.value[key]
        
        index.value += 1
        track.write_stack(self.path.clone << "@index", index)
        
        track.write_variable(self.variable, value)
        track.clear_stack(self.statements.path)
        track.should_visit(self.statements)
      end
      
    end
    
  end
  
  class Import < Node
    attribute :path
  end
  
  class Perform < Node
    
  end
  
  class Break < Node
    def visit(track)
      
      pointer = self
      
      while pointer = pointer.parent do
        if pointer.class == While || pointer.class == For then
          track.write_stack(self.path, ::Dog::Value.null_value)
          track.should_visit(pointer.parent)
          return
        end
      end
      
      # Ignore the break statement
      track.write_stack(self.path, ::Dog::Value.null_value)
      track.should_visit(self.parent)
      return
    end
  end
  
  class Return < Node
    attribute :expression
    
    def visit(track)
      return_value = ::Dog::Value.null_value
      
      if self.expression then
        unless track.has_visited?(self.expression) then
          track.should_visit(self.expression)
          return
        end
        
        return_value = track.read_stack(self.expression.path)
      end
      
      track.write_return_value(return_value)
      track.finish
      return
    end
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
    
    def visit(track)
      
      for item in value do
        unless track.has_visited? item.last then
          track.should_visit(item.last)
          return
        end
      end
      
      if self.type then
        if track.has_visited? self.type then
          dog_value = track.read_stack(self.type.path)
        else
          track.should_visit(self.type)
          return
        end
      else
        dog_value = ::Dog::Value.new("structure", {})
      end
      
      for item in value do
        k = item.first
        v = item.last
        
        if k.kind_of? Numeric then
          k = "n:#{k}"
        else
          k = "s:#{k}"
        end
        
        dog_value.value[k] = track.read_stack(v.path)
      end
      
      track.write_stack(self.path, dog_value)
      track.should_visit(self.parent)
    end
  end
  
  class StructureInstantiation < Node
    attribute :type
    
    def visit(track)
      track.save
      # TODO - For both function calls and structure instantiations
      # I should consider check the type to ensture that I am doing 
      # the right thing...
      
      # TODO - Also for types in both computes as well as literals, I need
      # to handle relative paths as well... hopefully, maybe?
      
      function = ::Dog::Track.new(self.type)
      function.control_ancestors = track.control_ancestors.clone
      function.control_ancestors.push(track.id)
      
      track.state = ::Dog::Track::STATE::CALLING
      return function
    end
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