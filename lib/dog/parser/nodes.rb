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
    def external_instructions
      instructions = nil
      
      if elements then
        for element in elements do
          instructions = element.external_instructions
          break unless instructions.nil?
        end
      end
      
      return instructions
    end
    
    def external_output
      output = nil
      
      if elements then
        for element in elements do
          output = element.external_output
          break unless output.nil?
        end
      end
      
      return output
    end
    
    def transform
      if elements && elements.first then
        return self.elements.first.transform
      else
        return nil
      end
    end
    
    def line
      1 + self.input.slice(0, self.interval.begin).count("\n")
    end
  end

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
          pop = ::Dog::Instructions::Pop.new
          set_instruction_context(pop)

          package.add_to_instructions([pop])
        end
      end
    end
  end
  
  class Package < Node
    attr_accessor :name
    
    def initialize(name)
      @name = name
    end
    
    def compile
      nil
    end
  end

  class ExternalFunctionDefinition < Node
    attr_accessor :name
    attr_accessor :actor
    attr_accessor :instructions
    attr_accessor :arguments
    attr_accessor :optional_arguments
    attr_accessor :output

    def initialize(name, actor, instructions = nil, arguments = nil, optional_arguments = nil, output = nil)
      @name = name
      @actor = actor
      @instructions = instructions
      @arguments = arguments
      @optional_arguments = optional_arguments
      @output = output
    end
    
    def compile(package)
      package.push_symbol(@name)
      
      value ::Dog::Value.new("external_function", {})
      value["package"] = ::Dog::Value.string_value(package.name)
      value["name"] = ::Dog::Value.string_value(@name)
      value["actor"] = ::Dog::Value.string_value(@actor)
      value["instructions"] = ::Dog::Value.string_value(@instructions)
      value["arguments"] = ::Dog::Value.string_value(@arguments)
      value["optional_arguments"] = ::Dog::Value.string_value(@optional_arguments)
      value["output"] = ::Dog::Value.string_value(@output)
      
      package.current_context["value"] = value
      
      package.pop_symbol
      
      # TODO - Push.new(value) instead of PushNull?
      null = ::Dog::Instructions::PushNull.new
      set_instruction_context(null)
      package.add_to_instructions([null])
    end
  end

  class FunctionDefinition < Node
    attr_accessor :name
    attr_accessor :implementation
    attr_accessor :arguments
    attr_accessor :optional_arguments
    
    def initialize(name, implementation = nil, arguments = nil, optional_arguments = nil)
      @name = name
      @implementation = implementation
      @arguments = arguments
      @optional_arguments = optional_arguments
    end
    
    def compile(package)
      package.push_symbol(@name)
      
      value = ::Dog::Value.new("function", {})
      value["name"] = ::Dog::Value.string_value(@name)
      value["package"] = ::Dog::Value.string_value(package.name)
      
      package.current_context["value"] = value
      
      if @implementation then
        package.add_implementation
        package.implementation["arguments"] = @arguments
        package.implementation["optional_arguments"] = @optional_arguments
        @implementation.compile(package)
      end
      
      package.pop_symbol
      
      # TODO - Push.new(value) instead of PushNull?
      null = ::Dog::Instructions::PushNull.new
      set_instruction_context(null)
      package.add_to_instructions([null])
    end
  end
  
  class StructureDefinition < Node
    attr_accessor :name
    attr_accessor :properties
    
    def initialize(name, properties)
      @name = name
      @properties = properties
    end
    
    def compile(package)
      package.push_symbol(@name)
      
      value = ::Dog::Value.new("type", {})
      value["name"] = ::Dog::Value.string_value(name)
      value["package"] = ::Dog::Value.string_value(package.name)
      
      package.current_context["value"] = @value
      
      package.add_implementation
      
      value = ::Dog::Value("#{package.name}.#{name}", {})
      structure = ::Dog::Instructions::Push.new(value)
      set_instruction_context(structure)
      add_to_instructions(structure)
      
      if @properties then
        for property in @properties do
          # TODO - Handle "type"
          name = property["name"]
          default = property["default"]
          
          if name.kind_of? String then
            push_string = ::Dog::Instructions::PushString.new(key)
            set_instruction_context(push_string)
            package.add_to_instructions([push_string])
          elsif name.kind_of? Numeric then
            push_number = ::Dog::Instructions::PushNumber.new(key)
            set_instruction_context(push_number)
            package.add_to_instructions([push_number])
          else
            raise "Compilation error"
          end
          
          if default then
            default.compile(package)
          else
            null = ::Dog::Instructions::PushNull.new
            set_instruction_context(null)
            package.add_to_instructions([null])
          end
          
          assign = ::Dog::Instructions::Assign.new(2)
          set_instruction_context(assign)
          package.add_to_instructions([assign])
        end
      end
      
      package.pop_symbol
      
      null = ::Dog::Instructions::PushNull.new
      set_instruction_context(null)
      package.add_to_instructions([null])
    end
  end
  
  class Definition < Node
    attr_accessor :name
    attr_accessor :value
    attr_accessor :implementation
    attr_accessor :arguments
    attr_accessor :optional_arguments
    
    def initialize(name, value = nil, implementation = nil, arguments = nil, optional_arguments = nil)
      @name = name
      @value = value
      @implementation = implementation
      @arguments = arguments
      @optional_arguments = optional_arguments
    end
    
    def compile(package)
      package.push_symbol(@name)
      
      if @value then
        package.current_context["value"] = @value
      end
      
      if @implementation then
        package.add_implementation
        package.implementation["arguments"] = @arguments
        package.implementation["optional_arguments"] = @optional_arguments
        @implementation.compile(package)
      end
      
      package.pop_symbol
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
      if @type then
        if @type.kind_of? Node then
          @type.compile(package)
        elsif @type.kind_of? ::Dog::Value
          push = ::Dog::Nodes::Push.new(@type)
          set_instruction_context(push)
          package.add_to_instructions([push])
        else
          raise "Compilation error"
        end

        build = ::Dog::Instructions::Build.new
        set_instruction_context(build)
        package.add_to_instructions([build])
      else
        structure = ::Dog::Instructions::PushStructure.new
        set_instruction_context(structure)
        package.add_to_instructions([structure])
      end

      for key, property in @value do
        if key.kind_of? String then
          push_string = ::Dog::Instructions::PushString.new(key)
          set_instruction_context(push_string)
          package.add_to_instructions([push_string])
        elsif key.kind_of? Numeric then
          push_number = ::Dog::Instructions::PushNumber.new(key)
          set_instruction_context(push_number)
          package.add_to_instructions([push_number])
        else
          raise "Compilation error"
        end

        property.compile(package)

        assign = ::Dog::Instructions::Assign.new(2)
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
      instruction = ::Dog::Instructions::PushString.new(value)
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
      instruction = ::Dog::Instructions::PushNumber.new(value)
      set_instruction_context(instruction)

      package.add_to_instructions([instruction])
    end
  end

  class TrueLiteral < Node
    def compile(package)
      instruction = ::Dog::Instructions::PushTrue.new
      set_instruction_context(instruction)

      package.add_to_instructions([instruction])
    end
  end

  class FalseLiteral < Node
    def compile(package)
      instruction = ::Dog::Instructions::PushFalse.new
      set_instruction_context(instruction)

      package.add_to_instructions([instruction])
    end
  end

  class NullLiteral < Node
    def compile(package)
      instruction = ::Dog::Instructions::PushNull.new
      set_instruction_context(instruction)

      package.add_to_instructions([instruction])
    end
  end

  class Assign < Node
    attr_accessor :path
    attr_accessor :value
    attr_accessor :scope

    # TODO - Handle scope

    def initialize(path, value)
      @path = path
      @value = value
    end

    def compile(package)
      for item in path do
        if item == path.first then
          read_variable = ::Dog::Instructions::ReadVariable.new(item)
          set_instruction_context(read_variable)
          package.add_to_instructions([read_variable])
        else
          if item.kind_of? Node then
            item.compile(package)
          elsif item.kind_of? String then
            string = ::Dog::Instructions::PushString.new(item)
            set_instruction_context(string)
            package.add_to_instructions([string])
          elsif item.kind_of? Numeric then
            number = ::Dog::Instructions::PushNumber.new(item)
            set_instruction_context(number)
            package.add_to_instructions([number])
          else
            raise "Compilation error"
          end
        end
      end

      value.compile(package)

      assign = ::Dog::Instructions::Assign.new(path.size)
      set_instruction_context(assign)
      package.add_to_instructions([assign])

      write_variable = ::Dog::Instructions::WriteVariable.new(path.first)
      set_instruction_context(write_variable)
      package.add_to_instructions([write_variable])
    end
  end

  class Access < Node
    attr_accessor :path
    attr_accessor :scope

    # TODO - Handle scope

    def initialize(path)
      @path = path
    end

    def compile(package)
      for item in path do
        if item == path.first then
          if item.kind_of? Node then
            # TODO - This is special cased for literals. This may be
            # something that should be fixed in the grammar.
            item.compile(package)
          else
            read_variable = ::Dog::Instructions::ReadVariable.new(item)
            set_instruction_context(read_variable)
            package.add_to_instructions([read_variable])
          end
        else
          if item.kind_of? Node then
            item.compile(package)
          elsif item.kind_of? String then
            string = ::Dog::Instructions::PushString.new(item)
            set_instruction_context(string)
            package.add_to_instructions([string])
          elsif item.kind_of? Numeric then
            number = ::Dog::Instructions::PushNumber.new(item)
            set_instruction_context(number)
            package.add_to_instructions([number])
          else
            raise "Compilation error"
          end
        end
      end

      access = ::Dog::Instructions::Access.new(path.size)
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

      perform = ::Dog::Instructions::Perform.new(self.operation)
      set_instruction_context(perform)

      package.add_to_instructions([perform])
    end
  end

  class Branch < Node
    attr_accessor :condition
    attr_accessor :true_nodes
    attr_accessor :false_nodes

    def initialize(condition, true_nodes = nil, false_nodes = nil)
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

      jump = ::Dog::Instructions::Jump.new(1 + false_nodes_instructions.size)
      set_instruction_context(jump)
      true_nodes_instructions.push(jump)

      jump_if_true = ::Dog::Instructions::JumpIfTrue.new(2)
      set_instruction_context(jump_if_true)
      instructions.push(jump_if_true)

      jump = ::Dog::Instructions::Jump.new(1 + true_nodes_instructions.size)
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

        pop = ::Dog::Instructions::Pop.new
        set_instruction_context(pop)
        body_instructions.push(pop)

        jump = ::Dog::Instructions::Jump.new(0 - body_instructions.size)
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
        null = ::Dog::Instructions::PushNull.new
        set_instruction_context(null)

        package.add_to_instructions([null])
      end

      t = ::Dog::Instructions::Throw.new("break")
      set_instruction_context(t)

      package.add_to_instructions([t])
    end
  end

  class AsyncCall < Node
    attr_accessor :actor
    attr_accessor :identifier
    attr_accessor :arguments
    attr_accessor :optional_arguments
    
    def initialize(actor, identifier, arguments = nil, optional_arguments = nil)
      @actor = actor
      @identifier = identifier
      @arguments = arguments
      @optional_arguments = optional_arguments
    end
    
    def compile(package)
      # TODO - check if identifier is not an access and create a function type automatically
      # This would be similar to StructureLiteral in many ways
      @actor.compile(package)
      @identifier.compile(package)
      
      @arguments ||= []
      for argument in @arguments do
        argument.compile(package)
      end
      
      @optional_arguments.compile(package) if @optional_arguments
      
      call = ::Dog::Instructions::AsyncCall.new(@arguments.count, !@optional_arguments.nil?)
      set_instruction_context(call)
      package.add_to_instructions([call])
    end
  end
  
  class Call < Node
    attr_accessor :identifier
    attr_accessor :arguments
    attr_accessor :optional_arguments
    
    def initialize(identifier, arguments = nil, optional_arguments = nil)
      @identifier = identifier
      @arguments = arguments
      @optional_arguments = optional_arguments
    end
    
    def compile(package)
      # TODO - check if identifier is not an access and create a function type automatically
      # This would be similar to StructureLiteral in many ways
      @identifier.compile(package)
      
      @arguments ||= []
      for argument in @arguments do
        argument.compile(package)
      end
      
      @optional_arguments.compile(package) if @optional_arguments
      
      call = ::Dog::Instructions::Call.new(@arguments.count, !@optional_arguments.nil?)
      set_instruction_context(call)
      package.add_to_instructions([call])
    end
  end

  class Return < Node
    attr_accessor :expression

    def initialize(expression = nil)
      @expression = expression
    end

    def compile(package)
      if @expression then
        @expression.compile(package)
      else
        null = ::Dog::Instructions::PushNull.new
        set_instruction_context(null)
        package.add_to_instructions([null])
      end

      r = ::Dog::Instructions::Return.new
      set_instruction_context(r)
      package.add_to_instructions([r])
    end
  end

  class Print < Node
    # TODO - Remove this in favor of a system library call
    attr_accessor :expression

    def initialize(expression)
      @expression = expression
    end

    def compile(package)
      if expression then
        expression.compile(package)
      else
        null = ::Dog::Instructions::PushNull.new
        set_instruction_context(null)
        package.add_to_instructions([null])
      end

      print = ::Dog::Instructions::Print.new
      set_instruction_context(print)
      package.add_to_instructions([print])
    end
  end
  
  
  
#  Missing:
#  
#  Package
#  FunctionDefinition
#  RemoteCall
# 
#  SystemCalls:
#  
#  Listen
#  Notify
#  Import(?)
#  
#  ReWrite:
#  
#  If
#  While
#  For
#  Break
#  
#  OnEachDefinition - Create a function and rewrite as a system call that sets the call back
#  
#  StructureDefinition - Rewrite to a function definition that creates the structure and returns it
#  StructureDefinitionProperty
#  
#  CommunityDefinition - Rewrite to a function definition that houses a system call that create a community if it does not exists and returns a meta structure...
#  CollectionDefinition
#  
#  ExternalDefinitions - Rewrite this as a function definition that returns a external function meta structure
#  
#  Remove:
#  
#  Inspect
#  Perform
#  StructureInstantiation
  
  
  
end