#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

# TODO - Right now linked libraries have to be statically linked. We may
# want the ability to dynamically link in the future as well...

# Current limitation with import:
#  - You have to link at compile time (static linked only)
#  - You cannot import the same file twice. The second import
#    will be ignored. And a compilation error will be reported...

module Dog::Rules
  
  class LinkImport < Rule
    
    Rule.register(self)
    
    def applicable_nodes
      [::Dog::Nodes::Import]
    end
    
    def apply(node)
      
      # TODO - Compile the string that is reported and insert it into the tree. You will need to add the symbols 
      # to the symbol table and report any compilation errors that may arise as well as any symbol mismatches...
    end
    
  end 
end
