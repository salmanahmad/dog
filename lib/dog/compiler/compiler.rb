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

    def self.compile(units)
      compiler = self.new
      for unit in units do
        raise "A compilation units must contain two elements [AST, filename]" unless unit.size == 2
        compiler.compile(unit[0], unit[1])
      end

      compiler.finalize
    end

    def initialize
      # TODO - Set the default package name from the project.config?
      self.bundle = Bundle.new
      self.errors = []
    end

    def compile(node, filename = "")
      package_name = ""

      # TODO - Fix this
      #::Dog::Nodes::Node.each_descendant(node) do |d|
      #  d.filename = filename
      #  if d.kind_of? ::Dog::Nodes::Package then
      #    package_name = d.name
      #  end
      #end

      package = self.bundle.packages[package_name]

      unless package then
        package = ::Dog::Package.new(package_name)
        self.bundle.link(package)
      end

      #::Dog::Nodes::Node.each_descendant(node) do |d|
      #  rule = Rules::Rule.new(self)
      #  rule.apply(d)
      #end

      if errors.empty? then
        node.compile(package)
      end
    end

    def finalize
      if errors.empty? then
        self.bundle.finalize
        self.bundle.sign
        return self.bundle
      else
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
    end
    
    def report_error_for_node(node, description)
      self.errors << "(#{node.filename}:#{node.line}) - #{description}"
    end
    
  end
  
end

