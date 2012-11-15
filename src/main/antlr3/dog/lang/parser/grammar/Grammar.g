
grammar Grammar;

options {
  output = AST;
  backtrack=true;
  ASTLabelType=CommonTree;
}

@parser::header { 
package dog.lang.parser.grammar;

import dog.lang.nodes.*;

import java.util.ArrayList;

}

@lexer::header {
package dog.lang.parser.grammar;
import dog.lang.nodes.*;
}


@lexer::members {
    // TODO - Better error reporting here --- http://www.antlr.org/wiki/display/ANTLR3/Error+reporting+and+recovery
    public void emitErrorMessage(String message) {
        throw new RuntimeException(message);
    }
}

program returns [Nodes nodes]
  : terminator? expressions? EOF! { $nodes = $expressions.nodes; }
  ;
	
expressions returns [Nodes nodes]
	:                      { $nodes = new Nodes(); }
    head=expression      { $nodes.add($head.node); }
    (
      terminator         
	    tail=expression    { $nodes.add($tail.node); }
	  )*
	  terminator?
  ;

expression returns [Node node]
	: assignmentExpression { $node = $assignmentExpression.node; }
  ;

assignmentExpression returns [Node node]
  : assignment           { $node = $assignment.node; }
  | e=orExpression         { $node = $e.node; }
  ;
  
orExpression returns [Node node]
  : node1=andExpression OR node2=orExpression { $node = new Operation($tree.getLine(), $node1.node, $node2.node, "||"); }
  | e=andExpression {$node = $e.node; }
  ;
  
andExpression returns [Node node]
  : node1=relationalExpression AND node2=andExpression { $node = new Operation($tree.getLine(), $node1.node, $node2.node, "&&"); }
  | e=relationalExpression { $node = $e.node; }
  ;

relationalExpression returns [Node node]
  : node1=additiveExpression relationalOperator node2=relationalExpression { $node = new Operation($start.getLine(), $node1.node, $node2.node, $relationalOperator.text); }
  | e=additiveExpression { $node = $e.node; }
  ;

additiveExpression returns [Node node]
  : node1=multiplicativeExpression additiveOperator node2=additiveExpression { $node = new Operation($start.getLine(), $node1.node, $node2.node, $additiveOperator.text); }
  | e=multiplicativeExpression { $node = $e.node; }
  ;

multiplicativeExpression returns [Node node]
  : node1=unaryExpresion multiplicativeOperator node2=multiplicativeExpression { $node = new Operation($start.getLine(), $node1.node, $node2.node, $multiplicativeOperator.text); }
  | e=unaryExpresion { $node = $e.node; }
  ;

unaryExpresion returns [Node node]
  : NOT node1=unaryExpresion { $node = new Operation($start.getLine(), $node1.node, null, "!"); }
  | primaryExpression { $node = $primaryExpression.node; }
  ;

primaryExpression returns [Node node]
  : IDENTIFIER
  | literal { $node = $literal.node; }
  ;

assignment returns [Node node]
  : IDENTIFIER ASSIGN expression
  ;


literal returns [Node node]
  : NUMBER { $node = new NumberLiteral($start.getLine(), Double.parseDouble($text)); }
  ;



relationalOperator 
  : EQUAL
  | NOT_EQUAL
  | IDENTICAL
  | NOT_IDENTICAL
  | LESS_THAN_EQUAL
  | GREATER_THAN_EQUAL
  | LESS_THAN
  | GREATER_THAN
  ;

additiveOperator
  : PLUS 
  | MINUS
  ;

multiplicativeOperator
  : MULTIPLY
  | DIVIDE
  | MODULO
  ;

terminator
  : (NEWLINE | SEMICOLON)+
  ;

DEFINE:             'define';
DO:		    		      'do';
END:                'end';
IF:                 'if';
ELSE:               'else';
WHILE:              'while';
REPEAT:             'repeat';
FOREVER:            'forever';
FOR:                'for';
ON:		  		        'on';
EACH:               'each';

IMPORT: 	          'import';
PACKAGE:	          'package';

WAIT:	              'wait';
STOP:	              'stop';
PAUSE:	            'pause';
EXIT:	              'exit';

PRINT:         	    'print';

STRING:             '"' ~('\\' | '"')* '"';
NUMBER:             '-'? DIGIT+ ('.' DIGIT+)?;

TRUE:               'true';
FALSE:              'false';

NULL:               'null';

IDENTIFIER:         LOWER CHAR*;

COLON:              ':';
SEMICOLON:          ';';
DOT:                '.';
COMMA:              ',';

OPEN_BRACKET:       '[';
CLOSE_BRACKET:      ']';
OPEN_PAREN:         '(';
CLOSE_PAREN:        ')';
OPEN_BRACE:         '{';
CLOSE_BRACE:        '}';

ASSIGN:             '=';

EQUAL:              '==';
NOT_EQUAL:	        '!=';
IDENTICAL:          '===';
NOT_IDENTICAL:      '!==';
LESS_THAN_EQUAL:    '<=';
GREATER_THAN_EQUAL: '>=';
LESS_THAN:          '<';
GREATER_THAN:       '>';

PLUS:               '+';
MINUS:              '-';

MULTIPLY:           '*';
DIVIDE:             '/';
MODULO:             '%';

AND:                '&&';
OR:                 '||';
NOT:                '!';

COMMENT:            '#' ~('\r' | '\n')* (NEWLINE | EOF) { skip(); };

NEWLINE:            '\r'? '\n';
WHITESPACE:         SPACE+ { $channel = HIDDEN; };

fragment CHAR:      LOWER | UPPER;
fragment LOWER:     'a'..'z';
fragment UPPER:     'A'..'Z';
fragment DIGIT:     '0'..'9';
fragment SPACE:     ' ' | '\t';
