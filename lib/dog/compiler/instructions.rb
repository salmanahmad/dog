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
    attr_accessor :line
    attr_accessor :file

    def name

    end

    def to_binary
      # TODO
    end

    def self.from_binary
      # TODO
    end

    def to_array

    end

    def self.from_array(array)

    end

    def execute(track)

    end
  end

  class Pop < Instruction
    def execute(track)
      track.stack.pop
    end
  end

  class Push < Instruction
    attr_accessor :value
    # TODO
  end

  class PushString < Instruction
    attr_accessor :value

    def initialize(value)
      @value = value
    end

    def execute(track)
      track.stack.push(@value)
    end
  end

  class PushNumber < Instruction
    attr_accessor :value

    def initialize(value)
      @value = value
    end

    def execute(track)
      track.stack.push(@value)
    end
  end

  class PushTrue < Instruction
    def execute(track)
      track.stack.push(true)
    end
  end

  class PushFalse < Instruction
    def execute(track)
      track.stack.push(false)
    end
  end

  class PushNull < Instruction
    def execute(track)
      track.stack.push(nil)
    end
  end

  class PushStructure < Instruction
    attr_accessor :type

    def initialize(type)
      @type = type
    end

    def execute(track)
      # TODO - Add the function call
      track.stack.push({})
    end
  end

  class Access < Instruction
    attr_accessor :path_size

    def initialize(path_size)
      @path_size = path_size
    end

    def execute(track)
      if @path_size > 1 then
        path = track.stack.pop(@path_size)
        pointer = path.shift
        for item in path do
          key = ""
          if item.kind_of? String then
            key = "s:#{item.to_s}"
          elsif item.kind_of? Numeric then
            key = "n:#{item.to_s}"
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
    attr_accessor :path_size

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
          if item.kind_of? String then
            key = "s:#{item.to_s}"
          elsif item.kind_of? Numeric then
            key = "n:#{item.to_s}"
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
    attr_accessor :variable_name

    def initialize(variable_name)
      @variable_name = variable_name
    end

    def execute(track)
      value = track.variables[@variable_name]
      track.stack.push(value)
    end
  end

  class WriteVariable < Instruction
    attr_accessor :variable_name

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
    attr_accessor :operation

    def initialize(operation)
      @operation = operation
    end

    def execute(track)
      case @operation
      when "<="
        arg2 = track.stack.pop
        arg1 = track.stack.pop

        track.stack.push(arg1 <= arg2)
      when ">="
        arg2 = track.stack.pop
        arg1 = track.stack.pop

        track.stack.push(arg1 >= arg2)
      when "+"
        arg2 = track.stack.pop
        arg1 = track.stack.pop

        track.stack.push(arg1 + arg2)
      when "-"
        arg2 = track.stack.pop
        arg1 = track.stack.pop

        track.stack.push(arg1 - arg2)
      when "*"
        arg2 = track.stack.pop
        arg1 = track.stack.pop

        track.stack.push(arg1 * arg2)
      when "/"
        arg2 = track.stack.pop
        arg1 = track.stack.pop

        track.stack.push(arg1 / arg2)
      when "!"
        arg1 = track.stack.pop

        track.stack.push(!arg1)
      else
        arg2 = track.stack.pop
        arg1 = track.stack.pop

        value = arg1.send(@operation, arg2)
        track.stack.push(value)

      end
    end
  end

  class Jump < Instruction
    attr_accessor :offset

    def initialize(offset)
      @offset = offset
    end

    def execute(track)
      track.next_instruction = track.current_instruction + @offset
    end
  end

  class JumpIfTrue < Instruction
    attr_accessor :offset

    def initialize(offset)
      @offset = offset
    end

    def execute(track)
      value = track.stack.pop

      if value then
        track.next_instruction = track.current_instruction + @offset
      end
    end
  end

  class JumpIfFalse < Instruction
    attr_accessor :offset

    def initialize(offset)
      @offset = offset
    end

    def execute(track)
      value = track.stack.pop

      unless value then
        track.next_instruction = track.current_instruction + @offset
      end
    end
  end

  class Throw < Instruction
    attr_accessor :symbol

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
    attr_accessor :arg_count

    # TODO
  end

  class Return < Instruction
    # TODO
  end

  class Print < Instruction
    def execute(track)
      message = track.stack.pop
      puts message

      track.stack.push(nil)
    end
  end
end