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
      self.push_symbol("@root")
      self.add_implementation
    end

    def to_hash
      processed_symbols = symbols.clone
      
      for name, symbol in symbols do
        processed_symbols[name] = symbol.clone
        processed_implementations = []
        
        for implementation in symbol["implementations"] do
          processed_implementation = implementation.clone
          processed_implementation["instructions"] = []
          
          for instruction in implementation["instructions"] do
            processed_implementation["instructions"] << instruction.to_hash
          end
          
          processed_implementations << processed_implementation
        end
        
        processed_symbols[name]["implementations"] = processed_implementations
        processed_symbols[name]["value"] = symbol["value"].to_hash if symbol["value"]
      end
      
      return {
        "name" => self.name,
        "symbols" => processed_symbols
      }
    end

    def self.from_hash(hash)
      package = self.new
      package.name = hash["name"]
      package.symbols = hash["symbols"]
      
      for name, symbol in package.symbols do
        implementations = []
        
        for implementation in symbol["implementations"] do
          
          implementation["instructions"].map! do |instruction|
            klass = ::Dog::Instructions::Instruction.class_from_hash(instruction)
            instruction = klass.from_hash(instruction)
            instruction
          end
          
          implementations << implementation
        end
        
        symbol["implementations"] = implementations
        symbol["value"] = ::Dog::Value.from_hash(symbol["value"]) if symbol["value"]
      end
      
      return package
    end

    def dump_bytecode
      dump = ""
      
      for name, symbol in self.symbols do
        for implementation in symbol["implementations"] do
          arg_list = []
          arg_count = implementation["arguments"].size rescue 0
          arg_count.times { arg_list << "void" }
          
          dump << "== asm:#{name}(#{arg_list.join(",")}) ==\n"
          dump << "== catch ==\n"
          
          for entry in implementation["catch_table"] do
            dump << entry.join(" ") << "\n"
          end
          
          dump << "\n"
          
          count = 0
          for instruction in implementation["instructions"] do
            dump << sprintf("%04d ", count) << instruction.bytecode.join(" ") << "\n"
            count += 1
          end
          
          dump << "\n"
          dump << "\n"
          
        end
      end
      
      return dump
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
      raise "You cannot finalize a package twice" if @finalized
      @finalized = true

      # TODO - Add bytecode verification. This include removing any duplicate empty symbols
      # TODO - Also consider catching patterns like push_nil pop

      for name, symbol in self.symbols do
        for implementation in symbol["implementations"] do
          table = []
          mapping = {}

          implementation["instructions"].each_index do |i|
            instruction = implementation["instructions"][i]
            mapping[instruction] = i
          end

          for entry in implementation["catch_table"] do
            new_entry = [
              mapping[entry[0]],
              mapping[entry[1]],
              entry[2],
              mapping[entry[1]] + entry[3]
            ]

            table.push(new_entry)
          end

          implementation["catch_table"] = table
        end
      end
    end
  end
end