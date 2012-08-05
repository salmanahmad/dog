#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog::Nodes
  class Node
    attr_accessor :line
    attr_accessor :file

    def compile(package)
      raise "Node#compile must be overridden by a subclass."
    end

    def set_instruction_context(instruction)
      instruction.line = self.line
      instruction.file = self.file
    end
  end

  class Nodes < Node
    attr_accessor :nodes

    def initialize(nodes)
      @nodes = nodes
    end

    def compile(package)
      for node in nodes do
        node.compile(package)
        unless node == nodes.last
          pop = Instructions::Pop.new
          set_instruction_context(pop)

          package.add_to_instructions([pop])
        end
      end
    end
  end

  class StructureLiteral < Node
    attr_accessor :type
    attr_accessor :value

    def initialize(type, value)
      @type = type
      @value = value
    end

    def compile(package)
      structure = Instructions::PushStructure.new(@type)
      set_instruction_context(structure)
      package.add_to_instructions([structure])

      for key, property in @value do
        if key.kind_of? String then
          push_string = Instructions::PushString.new(key)
          set_instruction_context(push_string)
          package.add_to_instructions([push_string])
        elsif key.kind_of? Numeric then
          push_number = Instructions::PushNumber.new(key)
          set_instruction_context(push_number)
          package.add_to_instructions([push_number])
        else
          raise "Compilation error"
        end

        property.compile(package)

        assign = Instructions::Assign.new(2)
        set_instruction_context(assign)
        package.add_to_instructions([assign])
      end
    end
  end

  class StringLiteral < Node
    attr_accessor :value

    def initialize(value)
      @value = value
    end

    def compile(package)
      instruction = Instructions::PushString.new(value)
      set_instruction_context(instruction)

      package.add_to_instructions([instruction])
    end
  end

  class NumberLiteral < Node
    attr_accessor :value

    def initialize(value)
      @value = value
    end

    def compile(package)
      instruction = Instructions::PushNumber.new(value)
      set_instruction_context(instruction)

      package.add_to_instructions([instruction])
    end
  end

  class TrueLiteral < Node
    def compile(package)
      instruction = Instructions::PushTrue.new
      set_instruction_context(instruction)

      package.add_to_instructions([instruction])
    end
  end

  class FalseLiteral < Node
    def compile(package)
      instruction = Instructions::PushFalse.new
      set_instruction_context(instruction)

      package.add_to_instructions([instruction])
    end
  end

  class NullLiteral < Node
    def compile(package)
      instruction = Instructions::PushNull.new
      set_instruction_context(instruction)

      package.add_to_instructions([instruction])
    end
  end

  class Assign < Node
    attr_accessor :path
    attr_accessor :value

    def initialize(path, value)
      @path = path
      @value = value
    end

    def compile(package)
      for item in path do
        if item == path.first then
          read_variable = Instructions::ReadVariable.new(item)
          set_instruction_context(read_variable)
          package.add_to_instructions([read_variable])
        else
          if item.kind_of? Node then
            item.compile(package)
          elsif item.kind_of? String then
            string = Instructions::PushString.new(item)
            set_instruction_context(string)
            package.add_to_instructions([string])
          elsif item.kind_of? Numeric then
            number = Instructions::PushNumber.new(item)
            set_instruction_context(number)
            package.add_to_instructions([number])
          else
            raise "Compilation error"
          end
        end
      end

      value.compile(package)

      assign = Instructions::Assign.new(path.size)
      set_instruction_context(assign)
      package.add_to_instructions([assign])

      write_variable = Instructions::WriteVariable.new(path.first)
      set_instruction_context(write_variable)
      package.add_to_instructions([write_variable])
    end
  end

  class Access < Node
    attr_accessor :path

    def initialize(path)
      @path = path
    end

    def compile(package)
      for item in path do
        if item == path.first then
          read_variable = Instructions::ReadVariable.new(item)
          set_instruction_context(read_variable)
          package.add_to_instructions([read_variable])
        else
          if item.kind_of? Node then
            item.compile(package)
          elsif item.kind_of? String then
            string = Instructions::PushString.new(item)
            set_instruction_context(string)
            package.add_to_instructions([string])
          elsif item.kind_of? Numeric then
            number = Instructions::PushNumber.new(item)
            set_instruction_context(number)
            package.add_to_instructions([number])
          else
            raise "Compilation error"
          end
        end
      end

      access = Instructions::Access.new(path.size)
      set_instruction_context(access)
      package.add_to_instructions([access])
    end
  end

  class Operation < Node
    attr_accessor :arg1
    attr_accessor :arg2
    attr_accessor :operation

    def initialize(arg1, arg2, operation)
      @arg1 = arg1
      @arg2 = arg2
      @operation = operation
    end

    def compile(package)
      if arg1 then
        arg1.compile(package)
      else
        raise "Compilation error: An operation must have at least one operand."
      end

      if arg2 then
        arg2.compile(package)
      end

      perform = Instructions::Perform.new(self.operation)
      set_instruction_context(perform)

      package.add_to_instructions([perform])
    end
  end

  class Branch < Node
    attr_accessor :condition
    attr_accessor :true_nodes
    attr_accessor :false_nodes

    def initialize(condition, true_nodes, false_nodes = nil)
      @condition = condition
      @true_nodes = true_nodes
      @false_nodes = false_nodes
    end

    def compile(package)
      condition.compile(package)
      instructions = package.instructions

      if true_nodes then
        package.instructions = []
        true_nodes.compile(package)
        true_nodes_instructions = package.instructions
      else
        true_nodes_instructions = []
      end

      if false_nodes then
        package.instructions = []
        false_nodes.compile(package)
        false_nodes_instructions = package.instructions
      else
        false_nodes_instructions = []
      end

      jump = Instructions::Jump.new(1 + false_nodes_instructions.size)
      set_instruction_context(jump)
      true_nodes_instructions.push(jump)

      jump_if_true = Instructions::JumpIfTrue.new(2)
      set_instruction_context(jump_if_true)
      instructions.push(jump_if_true)

      jump = Instructions::Jump.new(1 + true_nodes_instructions.size)
      set_instruction_context(jump)
      instructions.push(jump)

      instructions.concat(true_nodes_instructions)
      instructions.concat(false_nodes_instructions)

      package.instructions = instructions
    end
  end

  class Loop < Node
    attr_accessor :body

    def initialize(body)
      @body = body
    end

    def compile(package)
      if self.body then
        instructions = package.instructions

        package.instructions = []
        body.compile(package)
        body_instructions = package.instructions

        pop = Instructions::Pop.new
        set_instruction_context(pop)
        body_instructions.push(pop)

        jump = Instructions::Jump.new(0 - body_instructions.size)
        set_instruction_context(jump)
        body_instructions.push(jump)

        instructions.concat(body_instructions)

        package.instructions = instructions

        package.add_to_catch_table(body_instructions.first, body_instructions.last, "break", 1)
      end
    end
  end

  class Break < Node
    attr_accessor :expression

    def initialize(expression = nil)
      @expression = expression
    end

    def compile(package)
      if expression then
        expression.compile(package)
      else
        null = Instructions::PushNull.new
        set_instruction_context(null)

        package.add_to_instructions([null])
      end

      t = Instructions::Throw.new("break")
      set_instruction_context(t)

      package.add_to_instructions([t])
    end
  end

  class Call < Node
    # TODO
  end

  class Return < Node
    attr_accessor :expression

    def initialize(expression = nil)
      @expression = expression
    end

    def compile(package)
      if @expression then
        @expression.compile
      else
        null = Instructions::PushNull.new
        set_instruction_context(null)
        package.add_to_instructions([null])
      end

      r = Instructions::Return.new
      set_instruction_context(r)
      package.add_to_instructions([r])
    end
  end

  class Print < Node
    attr_accessor :expression

    def initialize(expression)
      @expression = expression
    end

    def compile(package)
      if expression then
        expression.compile(package)
      else
        null = Instructions::PushNull.new
        set_instruction_context(null)
        package.add_to_instructions([null])
      end

      print = Instructions::Print.new
      set_instruction_context(print)
      package.add_to_instructions([print])
    end
  end
end