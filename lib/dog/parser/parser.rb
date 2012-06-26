#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class ParseError < RuntimeError
    attr_accessor :line
    attr_accessor :column
    attr_accessor :failure_reason
  end
  
  class Parser
    
    Treetop.load(File.expand_path(File.join(File.dirname(__FILE__), 'grammar.treetop')))
    
    def self.parse(program, filename = "")
      parser = self.new
      parser.parse(program, filename)
    end
    
    attr_accessor :parser
    attr_accessor :should_clean_tree
    
    def initialize
      @parser = DogParser.new
      @should_clean_tree = true
    end
    
    def parse(program, filename = "")
      filename = File.expand_path(filename)
      
      tree = @parser.parse(program)
      
      if(tree.nil?)
        error = ParseError.new("Parse error in file: #{filename} at line: #{@parser.failure_line}, column: #{@parser.failure_column}.\n#{@parser.failure_reason.inspect}")
        
        error.line = @parser.failure_line
        error.column = @parser.failure_column
        error.failure_reason = @parser.failure_reason
        
        
        raise error
      end
      
      clean_tree(tree) if should_clean_tree
      
      return tree
    end
    
    private
    
      def clean_tree(root_node)
        return if(root_node.elements.nil?)
        
        root_node.elements.delete_if do |node| 
          node.class == Treetop::Runtime::SyntaxNode
        end
        
        root_node.elements.each do |node| 
          clean_tree(node) 
        end
      end
      
  end
  
end