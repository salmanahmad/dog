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

    class << self
      attr_accessor :grammar_loaded
    end

    def self.parse(program, filename = "")
      parser = self.new
      parser.parse(program, filename)
    end

    attr_accessor :parser

    def initialize
      unless Parser.grammar_loaded then
        Treetop.load(File.expand_path(File.join(File.dirname(__FILE__), 'grammar.treetop')))
        Parser.grammar_loaded = true
      end

      @parser = DogParser.new
      @should_clean_tree = false
    end

    def parse(program, filename = "")
      filename = File.expand_path(filename) unless filename.strip.length == 0

      tree = @parser.parse(program)
      
      if(tree.nil?)
        error = ParseError.new("Parsing error: (#{filename}:#{@parser.failure_line}).\n\n#{@parser.failure_reason.inspect}")

        error.line = @parser.failure_line
        error.column = @parser.failure_column
        error.failure_reason = @parser.failure_reason

        raise error
      end

      return tree.transform
    end

  end

end