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
        filename = File.expand_path(File.join(File.dirname(self.compiler.current_filename), filename))
      end
      
      file_contents = ""
      
      begin
        file = File.open(filename, "r")
        file_contents = file.read
      rescue
        report_error_for_node(node, "I could not open the imported file named: #{filename}. Are you sure this file exists?")
      end
      
      old_filename = self.compiler.current_filename
      
      self.compiler.current_filename = filename
      parser = ::Dog::Parser.new
      bark = parser.parse(file_contents, self.compiler.current_filename)
      self.compiler.compile(bark)
      
      self.compiler.current_filename = old_filename
    end
    
  end 
end
