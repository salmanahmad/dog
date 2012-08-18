#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog::Instructions
  class Instruction
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

    attribute :line
    attribute :file

    def to_hash
      hash = { "class" => self.class.name }
      
      for attribute in self.attributes do
        hash[attribute] = self.send(attribute.intern)
      end
      
      return hash
    end

    def self.from_hash(hash)
      klass = hash["class"]
      klass = Kernel::qualified_const_get(klass)
      object = klass.allocate
      
      for key, value in hash do
        if object.attributes.include? key then
          object.send("#{key.to_s}=".intern, value)
        end
      end
      
      return object
    end

    def bytecode
      name = ::Dog::Helper.underscore(self.class.name.split("::").last)
      code = [name.intern.inspect]
      
      for attribute in self.attributes.reverse do
        next if attribute.to_s == "line"
        next if attribute.to_s == "file"
        code << self.send(attribute.intern).inspect
      end
      
      return code
    end

    def execute(track)
      raise "Execute must be overridden by a subclass of instruction"
    end
  end

  class Pop < Instruction
    def execute(track)
      track.stack.pop
    end
  end

  class Push < Instruction
    attribute :value
    
    def initialize(value)
      @value = value
    end
    
    def execute(track)
      @value._id = UUID.new.generate
      track.stack.push(@value)
    end
    
    def to_hash
      hash = super
      hash["value"] = self.value.to_hash
    end
    
    def self.from_hash(hash)
      push = super(hash)
      push.value = ::Dog::Value.from_hash(push.value)
    end
    
    def bytecode
      code = super
      code.pop
      code.push(self.value.inspect)
      return code
    end
  end

  class PushString < Instruction
    attribute :value

    def initialize(value)
      @value = value
    end

    def execute(track)
      track.stack.push(::Dog::Value.string_value(@value))
    end
  end

  class PushNumber < Instruction
    attribute :value

    def initialize(value)
      @value = value
    end

    def execute(track)
      track.stack.push(::Dog::Value.number_value(@value))
    end
  end

  class PushTrue < Instruction
    def execute(track)
      track.stack.push(::Dog::Value.true_value)
    end
  end

  class PushFalse < Instruction
    def execute(track)
      track.stack.push(::Dog::Value.false_value)
    end
  end

  class PushNull < Instruction
    def execute(track)
      track.stack.push(::Dog::Value.null_value)
    end
  end

  class PushStructure < Instruction
    def execute(track)
      track.stack.push(::Dog::Value.empty_structure())
    end
  end
  
  class Access < Instruction
    attribute :path_size

    def initialize(path_size)
      @path_size = path_size
    end

    def execute(track)
      if @path_size > 1 then
        path = track.stack.pop(@path_size)

        if path.first.pending then
          puts path.first.inspect
          raise "Hi!"
          track.stack.concat(path)
          return
        end
        
        pointer = path.shift
        for item in path do
          key = ""
          
          item_value = item
          item_value = item.value if item.kind_of? ::Dog::Value
          
          if item_value.kind_of? String then
            key = item_value.to_s
          elsif item_value.kind_of? Numeric then
            key = item_value.to_s
          else
            raise "Runtime error"
          end

          pointer = pointer[key]
        end

        track.stack.push(pointer)
      end
    end
  end

  class Assign < Instruction
    attribute :path_size

    def initialize(path_size)
      @path_size = path_size
    end

    def execute(track)
      value = track.stack.pop
      path = track.stack.pop(@path_size)

      if @path_size == 1 then
        track.stack.push(value)
      else
        variable = path.shift
        pointer = variable

        for item in path do
          key = ""
          
          item_value = item
          item_value = item.value if item.kind_of? ::Dog::Value
          
          if item_value.kind_of? String then
            key = item_value.to_s
          elsif item_value.kind_of? Numeric then
            key = item_value.to_s
          else
            raise "Runtime error"
          end

          if item == path.last then
            pointer[key] = value
          else
            pointer = pointer[key]
          end
        end

        track.stack.push(variable)
      end
    end
  end

  class ReadVariable < Instruction
    attribute :variable_name

    def initialize(variable_name)
      @variable_name = variable_name
    end

    def execute(track)
      # TODO - Handle scope modifiers: internal, external, local
      if track.variables.include? @variable_name then
        value = track.variables[@variable_name]
      else
        package = track.package_name
        symbol = ::Dog::Runtime.bundle.packages[package].symbols[@variable_name]
        if symbol && !symbol["value"].nil? then
          value = symbol["value"]
        else
          package = ::Dog::Runtime.bundle.packages[@variable_name]
          if package then
            value = ::Dog::Value.new("package", {})
            
            for name, symbol in package.symbols do
              if symbol["value"] then
                value[name] = symbol["value"]
              else
                value[name] = ::Dog::Value.null_value
              end
            end
          else
            value = ::Dog::Value.null_value
          end
        end
      end
      
      track.stack.push(value)
    end
  end

  class WriteVariable < Instruction
    attribute :variable_name

    def initialize(variable_name)
      @variable_name = variable_name
    end

    def execute(track)
      value = track.stack.pop
      track.variables[@variable_name] = value
      track.stack.push(value)
    end
  end

  class Perform < Instruction
    attribute :operation

    def initialize(operation)
      @operation = operation
    end

    def execute(track)
      case @operation
      when "OR"
        arg2 = track.stack.pop.ruby_value
        arg1 = track.stack.pop.ruby_value
        
        value = arg1 || arg2
        value = ::Dog::Value.from_ruby_value(value)
        track.stack.push(value)
      when "AND"
        arg2 = track.stack.pop.ruby_value
        arg1 = track.stack.pop.ruby_value
        
        value = arg1 && arg2
        value = ::Dog::Value.from_ruby_value(value)
        track.stack.push(value)
      when "!"
        arg1 = track.stack.pop

        track.stack.push(!arg1)
      else
        arg2 = track.stack.pop.ruby_value
        arg1 = track.stack.pop.ruby_value

        value = arg1.send(@operation, arg2)
        value = ::Dog::Value.from_ruby_value(value)
        track.stack.push(value)
      end
    end
  end

  class Jump < Instruction
    attribute :offset

    def initialize(offset)
      @offset = offset
    end

    def execute(track)
      track.next_instruction = track.current_instruction + @offset
    end
  end

  class JumpIfTrue < Instruction
    attribute :offset

    def initialize(offset)
      @offset = offset
    end

    def execute(track)
      value = track.stack.pop

      unless value.is_false? || value.is_null? then
        track.next_instruction = track.current_instruction + @offset
      end
    end
  end

  class JumpIfFalse < Instruction
    attribute :offset

    def initialize(offset)
      @offset = offset
    end

    def execute(track)
      value = track.stack.pop

      if value.is_false? || value.is_null? then
        track.next_instruction = track.current_instruction + @offset
      end
    end
  end

  class Throw < Instruction
    attribute :symbol

    def initialize(symbol)
      @symbol = symbol
    end

    def execute(track)
      best_entry = nil

      for entry in track.context["catch_table"] do
        if entry[2] == @symbol then
          if entry[0] <= track.current_instruction && entry[1] >= track.current_instruction then
            if best_entry.nil? then
              best_entry = entry
            else
              difference = entry[1] - entry[0]
              if difference < (best_entry[1] - best_entry[0]) then
                best_entry = entry
              end
            end
          end
        end
      end

      if best_entry.nil? then
        raise "Uncaught throw instruction"
      else
        track.next_instruction = best_entry[3]
      end
    end
  end

  class Call < Instruction
    attribute :arg_count
    attribute :has_optionals

    def initialize(arg_count, has_optionals)
      @arg_count = arg_count
      @has_optionals = has_optionals
    end
    
    def execute(track)
      optionals = nil
      optionals = track.stack.pop if has_optionals
      
      arguments = track.stack.pop(arg_count)
      function = track.stack.pop
      
      if function.type != "function" then
        raise "I don't know how to call a non-function"
      end
      
      package = function["package"].value
      name = function["name"].value
      implementation = 0
      
      # TODO - Handle default values
      # Perhaps the default values for optional args are handled
      # by the runtime libraries and not the VM
      
      new_track = ::Dog::Track.new
      new_track.control_ancestors = track.control_ancestors.clone
      new_track.control_ancestors << track
      
      new_track.package_name = package
      new_track.function_name = name
      new_track.implementation_name = implementation
      
      symbol = ::Dog::Runtime.bundle.packages[package].symbols[name]["implementations"][implementation]
      symbol_arguments = symbol["arguments"]
      
      arguments.each_index do |index|
        argument = arguments[index]
        variable_name = symbol_arguments[index]
        new_track.variables[variable_name] = argument
      end
      
      track.state = ::Dog::Track::STATE::CALLING
      track.next_track = new_track
    end
  end

  class AsyncCall < Instruction
    attribute :arg_count
    attribute :has_optionals
    
    def initialize(arg_count, has_optionals)
      @arg_count = arg_count
      @has_optionals = has_optionals
    end
    
    def execute(track)
      optionals = nil
      optionals = track.stack.pop if has_optionals
      
      arguments = track.stack.pop(arg_count)
      function = track.stack.pop
      actor = track.stack.pop
      
      # TODO
    end
  end
  
  class Build < Instruction
    def execute(track)
      type = track.stack.pop
      
      if type.type != "type" then
        raise "I don't know how to build a non-type"
      end
      
      new_track = ::Dog::Track.new
      new_track.control_ancestors = track.control_ancestors.clone
      new_track.control_ancestors << track
      
      new_track.package_name = type["package"].value
      new_track.function_name = type["name"].value
      new_track.implementation_name = 0
      
      track.state = ::Dog::Track::STATE::CALLING
      track.next_track = new_track
    end
  end

  class Return < Instruction
    def execute(track)
      track.finish
    end
  end
end