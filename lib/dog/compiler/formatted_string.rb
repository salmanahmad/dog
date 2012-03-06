#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class FormattedString
    
    def initialize
      @buffer = StringIO.new
      @line_buffer = StringIO.new
      @indent = 0
    end
    
    def <<(lines)
      if lines.include? "\n" then
        
        @line_buffer << lines
        lines = @line_buffer.string
        
        @line_buffer = StringIO.new
        
        lines.each_line do |line|
          @buffer << indent_spaces << line << "\n"
        end
      else
        @line_buffer << lines
      end
    end
    
    def indent
      @indent += 2
    end
    
    def unindent
      @indent -= 2
      @indent = 0 if @indent < 0
    end
    
    def indent_spaces
      indents = ""
      @indent.times do
        indents += " "
      end
      return indents
    end
    
    def string
      return @buffer.string
    end
    
    def to_s
      string
    end
    
  end
  
end