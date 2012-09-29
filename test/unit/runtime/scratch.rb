#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class RuntimeTests::ScratchTest < Test::Unit::TestCase
  include RuntimeHelper
  include Dog

  def print_helper(expression)
    ::Dog::Nodes::Call.new(
      ::Dog::Nodes::Access.new(["system", "print"]),
      [expression]
    )
  end

  def test_simple
    program = Nodes::Nodes.new([
      Nodes::Assign.new(["i"], Nodes::StringLiteral.new("Hello, World!")),
      Nodes::Access.new(["i"])
    ])

    track = run_nodes(program).first

    assert_equal("Hello, World!", track.stack.last.ruby_value)
  end

  def test_function_call
    program = Nodes::Nodes.new([
      Nodes::FunctionDefinition.new("foo", Nodes::Nodes.new([
        print_helper(Nodes::StringLiteral.new("Foo Called!"))
      ])),
      Nodes::Call.new(Nodes::Access.new(["foo"]))
    ])

    tracks, out = run_nodes(program, true)
    assert_equal("Foo Called!", out)
  end
  
  def test_function_returns
    program = Nodes::Nodes.new([
      Nodes::FunctionDefinition.new("foo", Nodes::Nodes.new([
        print_helper(Nodes::StringLiteral.new("Foo Called!")),
        Nodes::Return.new(Nodes::NumberLiteral.new(3.14))
      ])),
      Nodes::Call.new(Nodes::Access.new(["foo"]))
    ])
    
    tracks, out = run_nodes(program, true)
    
    assert_equal(3.14, tracks.last.stack.last.ruby_value)
    assert_equal("Foo Called!", out)
  end
  
  def test_function_arguments
    program = Nodes::Nodes.new([
      Nodes::FunctionDefinition.new("add", ["a", "b"], Nodes::Nodes.new([
        Nodes::Return.new(Nodes::Operation.new(Nodes::Access.new(["a"]), Nodes::Access.new(["b"]), "+"))
      ])),
      Nodes::Call.new(Nodes::Access.new(["add"]), [Nodes::NumberLiteral.new(5), Nodes::NumberLiteral.new(4)])
    ])
    
    tracks = run_nodes(program)
    assert_equal(9, tracks.last.stack.last.ruby_value)
  end
  
  def test_function_implicit_returns
    program = Nodes::Nodes.new([
      Nodes::FunctionDefinition.new("add", ["a", "b"], Nodes::Nodes.new([
        Nodes::Operation.new(Nodes::Access.new(["a"]), Nodes::Access.new(["b"]), "+")
      ])),
      Nodes::Call.new(Nodes::Access.new(["add"]), [Nodes::NumberLiteral.new(5), Nodes::NumberLiteral.new(4)])
    ])
    
    tracks = run_nodes(program)
    assert_equal(9, tracks.last.stack.last.ruby_value)
  end
end
