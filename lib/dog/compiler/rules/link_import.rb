#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog::Rules
  
  class LinkImport < Rule
    
    Rule.register(self)
    
    def applicable_nodes
      [::Dog::Nodes::Import]
    end
    
    def apply(node)
      filename = node.filename
      
      if filename[0,1] != "/" then
        filename = File.join(File.dirname(self.compiler.current_filename), filename)
      end
      
      old_filename = self.compiler.current_filename
      
      self.compiler.current_filename = filename
      parser = ::Dog::Parser.new
      bark = parser.parse(File.open(self.compiler.current_filename, "r").read, self.compiler.current_filename)
      self.compiler.compile(bark)
      
      self.compiler.current_filename = old_filename
    end
    
  end 
end
