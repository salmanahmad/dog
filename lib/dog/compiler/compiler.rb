#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class CompilationError < RuntimeError
    attr_accessor :errors
  end
  
  class Compiler
    
    attr_accessor :bundle
    attr_accessor :errors
    
    attr_accessor :current_package
    attr_accessor :packages_to_finalize
    
    def self.compile(units)
      compiler = self.new
      for unit in units do
        raise "A compilation units must contain two elements" unless unit.length == 2
        compiler.compile(unit[0], unit[1])
      end
      
      compiler.finalize
    end
    
    def initialize
      # TODO - Set the default package name from the project.config?
      self.bundle = Bundle.new
      self.packages_to_finalize = []
      self.errors = []
    end
    
    def compile(node, filename = "")
      # TODO - The default package is blank. Is that okay?
      package = ""
      
      ::Dog::Nodes::Node.each_descendant(node) do |d|
        d.filename = filename
        if d.kind_of? ::Dog::Nodes::Package then
          package = d.name
        end
      end
      
      self.packages_to_finalize << package
      
      unless self.bundle.packages[package] then
        root = ::Dog::Nodes::Nodes.new
        root.nodes = []
            
        self.bundle.packages[package] = {
          "symbols" => {},
          "code" => root
        }
      end
      
      self.bundle.packages[package]["code"].nodes << node
    end
    
    def link(package)
      # TODO
    end
    
    def finalize
      for package in self.packages_to_finalize do
        self.current_package = package
        
        node = self.bundle.packages[package]["code"]
        node.compute_paths_of_descendants
        
        ::Dog::Nodes::Node.each_descendant(node) do |d|
          rule = Rules::Rule.new(self)
          rule.apply(d)
        end
      end
      
      unless errors.empty?
        compilation_error = nil
        
        if errors.size == 1 then 
          failure_reason = "Compilation Error: There was #{errors.size} error that took place.\n\n#{errors.join("\n\n")}\n"
          compilation_error = CompilationError.new(failure_reason)
        else 
          failure_reason = "Compilation Error: There was #{errors.size} error that took place.\n\n#{errors.join("\n\n")}\n"
          compilation_error = CompilationError.new("Compilation Error: There were #{errors.size} errors that took place.\n\n#{errors.join("\n\n")}\n")
        end
          
        compilation_error.errors = errors
        raise compilation_error
      end
      
      self.bundle.sign
      return self.bundle
    end
    
    def contains_symbol_in_current_package?(symbol)
      self.bundle.contains_symbol_in_package?(symbol, self.current_package)
    end
    
    def add_symbol_to_current_package(symbol, path)
      self.bundle.add_symbol_to_package(symbol, path, self.current_package)
    end
    
    def report_error_for_node(node, description)
      self.errors << "(#{node.filename}:#{node.line}) - #{description}"
    end
    
  end
  
end

