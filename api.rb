
require 'ap'
require 'pp'

alias statement lambda


#conditionals
#functions

class Array
  def 
    
  end
end

def closure(name, stack)
  return stack
end


break_statement = statement {
  # Breaks out of a loop. Goes to the next line. Goes out two levels.
}

retry_statement = statement {
  # Breaks out of the loop. Goes to the same line (re-executes the instruction). Goes out two levels.
}

redo_statement = statement {
  # Goes to the top of the block. Does not break out.
}

next_statement = statement {
  # Goes to the end of the block. (length + 1). This should point to nil
}

exit_branch = statement {
  
}

def while_statement(block, code)
  return [statement { }, code, statement { "go to the top" }]
end

def branch_statement(code)
  return code
end

def if_statement(block, code)
  return [block, code, statement { "break out" }]
end

foo = closure("foo", [
  statement { variable["sum"] = 5 + 10 },
  statement { variable["sum"] = variable["sum"] + 10 },
  while_statement(statement { variable["sum"] == 25 }, [
    statement { }
  ]),
  branch_statement([
    if_statement(statement { true }, [
      statement { print "if" }
    ]),
    if_statement( statement { false }, [
      statement { print "elseif" }
    ]), [
      statement { print "else" }
    ]
  ]),
  statement {  },
  statement {  },
  statement {  }
])


[
  "closure",
  statement { variable["sum"] = 5 + 10 },
  statement { variable["sum"] = variable["sum"] + 10 },
  [
    "while",
    statement { variable["sum"] == 25 },
    [
      
    ]
  ]
  while_statement(, [
    statement { }
  ]),
  branch_statement([
    if_statement(statement { true }, [
      statement { print "if" }
    ]),
    if_statement( statement { false }, [
      statement { print "elseif" }
    ]), [
      statement { print "else" }
    ]
  ]),
  statement {  },
  statement {  },
  statement {  }
])







foo = closure("foo", [
    
  ]
)

statement { variable["sum"] = 5 + 10 }

ap foo

