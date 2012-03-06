#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class CodeBuffer
    
    attr_accessor :header_scope
    attr_accessor :function_scope
    attr_accessor :server_scope
    attr_accessor :program_scope
    
    attr_accessor :scopes
    
    def initialize
      self.header_scope = FormattedString.new
      self.function_scope = FormattedString.new
      self.server_scope = FormattedString.new
      self.program_scope = FormattedString.new
      
      self.scopes = []
    end
    
    def push_scope(scope)
      self.scopes.push(scope)
    end
    
    def pop_scope
      self.scopes.pop
    end
    
    def current_scope
      case scopes.last
      when :header
        self.header_scope
      when :function
        self.function_scope
      when :server
        self.server_scope
      when :program
        self.program_scope
      else
        raise "Invalid scope used in Code Generator: #{scopes.last}"
      end
    end
    
    def <<(lines)
      self.current_scope << lines
    end
    
    def generate
      # TODO - This should generate the complete code file with all the bells and whistles
    end
    
  end
  
end