#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class State
    
    attr_accessor :parent
    attr_accessor :children
    
    attr_accessor :variable_dependencies
    attr_accessor :variable_output
    
    attr_accessor :operation
    
  end
  
end