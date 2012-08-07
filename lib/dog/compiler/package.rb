#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  class Package
    attr_accessor :name
    attr_accessor :symbols
    attr_accessor :symbols_stack

    def initialize(name = nil)
      self.name = name
      self.symbols = {}
      self.symbols_stack = []
      push_symbol("@root")
    end

    def pop_symbol
      self.symbols_stack.pop
    end

    def push_symbol(symbol)
      self.symbols[symbol] ||= {
        "name" => symbol,
        "value" => nil,
        "implementations" => [],
      }
      self.symbols_stack.push(symbol)
    end

    def current_symbol
      self.symbols_stack.last
    end
    
    def current_context
      self.symbols[self.current_symbol]
    end
    
    def implementation
      self.symbols[self.current_symbol]["implementations"].last
    end
    
    def instructions
      self.symbols[self.current_symbol]["implementations"].last["instructions"]
    end

    def instructions=(instructions)
      self.symbols[self.current_symbol]["implementations"].last["instructions"] = instructions
    end

    def catch_table
      self.symbols[self.current_symbol]["implementations"].last["catch_table"]
    end

    def add_implementation
      self.symbols[self.current_symbol]["implementations"] << {
        "arguments" => [],
        "optional_arguments" => [],
        "instructions" => [],
        "catch_table" => []
      }
    end

    def add_to_instructions(instructions)
      self.instructions.concat(instructions)
    end

    def add_to_catch_table(starting_instruction, ending_instruction, label, offset_from_end)
      entry = [starting_instruction, ending_instruction, label, offset_from_end]
      self.catch_table.push(entry)
    end

    def finalize
      # TODO - Add bytecode verification. This include removing any duplicate empty symbols
      
      for name, symbol in self.symbols do
        table = []
        mapping = {}

        instructions.each_index do |i|
          instruction = instructions[i]
          mapping[instruction] = i
        end

        for entry in symbol["catch_table"] do
          new_entry = [
            mapping[entry[0]],
            mapping[entry[1]],
            entry[2],
            mapping[entry[1]] + entry[3]
          ]

          table.push(new_entry)
        end

        symbol["catch_table"] = table
      end
    end
  end
end