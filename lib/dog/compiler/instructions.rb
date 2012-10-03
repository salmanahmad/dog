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

    def self.class_from_hash(hash)
      klass = hash["class"]
      klass = Kernel::qualified_const_get(klass)
      return klass
    end

    def self.from_hash(hash)
      klass = class_from_hash(hash)
      object = klass.allocate
      
      for key, value in hash do
        if object.attributes.include? key.intern then
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
      return hash
    end
    
    def self.from_hash(hash)
      push = super(hash)
      push.value = ::Dog::Value.from_hash(push.value)
      return push
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
  
  class Wait < Instruction
    def execute(track)
      value = track.stack.pop

      if value.pending then
        future = ::Dog::Future.find_one({"value_id" => value._id})
        
        if future.nil?
          raise "Runtime error: Could not find the future"
        end
        
        if future.queue.kind_of?(Array) && future.queue.size > 0 then
          value = future.queue.shift
          future.save
          track.stack.push(value)
        elsif !future.value.nil? then
          value = future.value
          track.stack.push(value)
        else
          future.broadcast_tracks << track
          future.save
          
          track.state = ::Dog::Track::STATE::WAITING
        end
      else
        track.stack.push(value)
      end
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

        pointer = nil

        count = -1
        for item in path do
          count += 1

          if count == 0 then
            pointer = item
          else
            key = ""

            item_value = item
            item_value = item.value if item.kind_of? ::Dog::Value

            if item_value.kind_of? String then
              key = item_value.to_s
            elsif item_value.kind_of? Numeric then
              key = item_value.to_f
            else
              raise "Access error"
            end

            pointer = pointer[key]
            pointer = ::Dog::Value.null_value if pointer.nil?
          end

          if count >= path.size - 1 then
            break
          else
            if pointer.pending then
              future = ::Dog::Future.find_one({"value_id" => pointer._id})

              if future.nil? then
                raise "Runtime error: Could not find the future"
              end

              if !future.value.nil? then
                pointer = future.value
              else
                future.blocking_tracks << track
                future.save

                track.stack.concat(path)
                track.next_instruction = track.current_instruction
                track.state = ::Dog::Track::STATE::WAITING
                return
              end
            end
          end
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
            key = item_value
            #key = item_value.to_s
          elsif item_value.kind_of? Numeric then
            key = item_value
            #key = item_value.to_s
          else
            raise "Runtime error"
          end

          # TODO - THis is a bug here... I need to count...
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
    attribute :scope

    def initialize(variable_name, scope = "cascade")
      @variable_name = variable_name
      @scope = scope
    end

    def execute(track)
      value = nil
      
      if value.nil? && ["cascade", "local"].include?(scope) then
        if track.variables.include? @variable_name then
          value = track.variables[@variable_name]
        end
      end
      
      if value.nil? && ["cascade", "internal"].include?(scope) then
        package = track.package_name
        symbol = ::Dog::Runtime.bundle.packages[package].symbols[@variable_name]
        if symbol && !symbol["value"].nil? then
          value = symbol["value"]
        end
      end
      
      if value.nil? && ["cascade", "external"].include?(scope) then
        package = ::Dog::Runtime.bundle.packages[@variable_name]
        
        if package then
          value = ::Dog::Value.new("dog.package", {})
          
          for name, symbol in package.symbols do
            if symbol["value"] then
              value[name] = symbol["value"]
            else
              value[name] = ::Dog::Value.null_value
            end
          end
        end
      end
      
      if value.nil? then
        value = ::Dog::Value.null_value
      end
      
      if value.pending then
        if track.futures[value._id] then
          value = track.futures[value._id]
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
    attribute :async

    def initialize(arg_count, async = false)
      @arg_count = arg_count
      @async = async
    end

    def execute(track)
      arguments = track.stack.pop(arg_count)
      function = track.stack.pop

      if function.type == "dog.function" then
        package = function["package"].value
        name = function["name"].value
        
        signal = ::Dog::Signal.new
        
        if @async then
          # TODO - Handle the return value as a future
          new_track = ::Dog::Track.invoke(name, package, arguments)
          signal.schedule_tracks = [new_track]
        else
          new_track = ::Dog::Track.invoke(name, package, arguments, track)
          signal.call_track = new_track
          
          track.state = ::Dog::Track::STATE::CALLING
        end
        
        return signal
      else
        raise "I don't know how to call a non-function"
      end
    end
  end
  
  class Build < Instruction
    def execute(track)
      type = track.stack.pop
      
      if type.type != "dog.type" then
        raise "I don't know how to build a non-type"
      end
      
      new_track = ::Dog::Track.new
      new_track.control_ancestors = track.control_ancestors.clone
      new_track.control_ancestors << track
      
      new_track.package_name = type["package"].value
      new_track.function_name = type["name"].value
      new_track.implementation_name = 0
      
      track.state = ::Dog::Track::STATE::CALLING
      
      signal = ::Dog::Signal.new
      signal.call_track = new_track
      return signal
    end
  end

  class Return < Instruction
    def execute(track)
      track.finish
    end
  end
end