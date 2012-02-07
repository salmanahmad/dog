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
    
  end
  
  class Parser
    
    Treetop.load(File.expand_path(File.join(File.dirname(__FILE__), 'grammar.treetop')))
    
    def self.parse(program)
      parser = self.class.new
      parser.parse(program)
    end
    
    attr_accessor :parser
    attr_accessor :should_clean_tree
    
    def initialize
      @parser = DogParser.new
      @should_clean_tree = true
    end
    
    def parse(program)
      tree = @parser.parse(program)
      
      if(tree.nil?)
        raise ParseError.new("Parse error at line: #{@parser.failure_line}, column: #{@parser.failure_column}.\n#{@parser.failure_reason}")
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