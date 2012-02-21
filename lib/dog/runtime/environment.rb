#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class Environment
    
    class << self
      attr_accessor :program_path
      
      def program_path=(path)
        @program_path = File.absolute_path(path)
      end
      
      def program_directory
        File.dirname(@program_path)
      end
      
    end
    
  end
  
end