
grammar Grammar;

options {
  output = AST;
  backtrack=true;
  ASTLabelType=CommonTree;
}

@parser::header { 
package dog.lang.parser.grammar;

import dog.lang.nodes.*;
import dog.lang.compiler.Identifier;

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
  : assignment             { $node = $assignment.node; }
  | e=orExpression         { $node = $e.node; }
  ;
  
orExpression returns [Node node]
  : n1=andExpression { $node = $n1.node; }
    ( OR
      n2=orExpression { $node = new Operation($start.getLine(), $n1.node, $n2.node, "||"); }
    )?
  ;

andExpression returns [Node node]
  : n1=relationalExpression { $node = $n1.node; }
    ( AND
      n2=andExpression { $node = new Operation($start.getLine(), $n1.node, $n2.node, "&&"); }
    )?
  ;

relationalExpression returns [Node node]
  : n1=additiveExpression { $node = $n1.node; }
    ( relationalOperator
      n2=relationalExpression { $node = new Operation($start.getLine(), $n1.node, $n2.node, $relationalOperator.text); }
    )?
  ;

additiveExpression returns [Node node]
  : n1=multiplicativeExpression   { $node = $n1.node; }
    ( additiveOperator
      n2=additiveExpression       { $node = new Operation($start.getLine(), $n1.node, $n2.node, $additiveOperator.text); }
    )?
  ;

multiplicativeExpression returns [Node node]
  : n1=unaryExpresion             { $node = $n1.node; }
    ( multiplicativeOperator
      n2=multiplicativeExpression { $node = new Operation($start.getLine(), $n1.node, $n2.node, $multiplicativeOperator.text); }
    )?
  ;

unaryExpresion returns [Node node]
  : NOT node1=unaryExpresion { $node = new Operation($start.getLine(), $node1.node, null, "!"); }
  | primaryExpression { $node = $primaryExpression.node; }
  ;

primaryExpression returns [Node node]
  : literal { $node = $literal.node; }
  | access  { $node = $access.node; }
  | call
  | functionDefinition
  | structureDefinition
  | collectionDefinition
  | controlStructure
  | timingStructure
  | waitStatement
  | spawnStatement
  | packageDeclaration
  | importStatement
  | onEachStatement
  | onStatement
  ;

assignment returns [Node node]
  : IDENTIFIER 
    ( accessPath
    )?
    ASSIGN 
    expression
  ;

access returns [Node node]
  : ( literal
    | identifierPath
    | OPEN_PAREN expression CLOSE_PAREN
    )
    ( accessPath
    )?
  ;

accessPath returns [ArrayList<Object> path]
  : accessDot
  | accessBracket
  ;

accessDot returns [ArrayList<Object> path]
  : DOT 
    IDENTIFIER
    ( accessPath
    )?
  ;

accessBracket returns [ArrayList<Object> path]
  : OPEN_BRACKET
    expression
    CLOSE_BRACKET
    ( accessPath
    )?
  ;

identifierPath returns [Identifier identifier]
  : ( CASCADE
    | EXTERNAL
    | INTERNAL
    | LOCAL
    )?
    IDENTIFIER
    ( DOT
      IDENTIFIER
    )*
  ;

call returns [Node node]
  : ( identifierPath
    )?
    PARAMETER
    expression
    ( PARAMETER
      expression
    )*
  ;


functionDefinition returns [Node node]
  : functionWithArguments
  | functionWithoutArguments
  ;

functionWithArguments returns [Node node]
  : DEFINE
    PARAMETER
    IDENTIFIER
    (
      PARAMETER
      IDENTIFIER
    )?
    DO
    expressions?
    END
  ;

functionWithoutArguments returns [Node node]
  : DEFINE
    IDENTIFIER
    DO
    terminator?
    expressions?
    END
  ;


structureDefinition returns [Node node]
  : DEFINE
    IDENTIFIER
    OPEN_BRACE
    ( structureAssociation
    )?
    ( (COMMA | terminator)
      structureAssociation
    )*
    CLOSE_BRACE
  ;

collectionDefinition
  : DEFINE
    COLLECTION
    IDENTIFIER
  ;

controlStructure
  : ifStatement
  | forLoop
  | whileLoop
  | repeatLoop
  | foreverLoop
  | breakStatement
  | returnStatement
  ;

ifStatement
  : IF 
    expression
    (THEN | DO) terminator?
    ( elseIfStatement
    )*
    ( elseStatement
    )?
    END
  ;

elseIfStatement
  : ELSE 
    IF
    expression
    (THEN | DO) terminator?
    ( expressions
    )?
  ;

elseStatement
  : ELSE
    ( expressions
    )?
  ;


forLoop
  : FOR EACH
    IDENTIFIER
    IN
    expression
    DO terminator?
    ( expressions
    )?
    END
  ;

whileLoop
  : WHILE
    expression
    DO terminator?
    ( expressions
    )?
    END
  ;

repeatLoop
  : REPEAT
    expression
    (TIMES | DO) terminator?
    ( expressions
    )?
    END
  ;

foreverLoop
  : FOREVER DO
    ( expressions
    )?
    END
  ;

breakStatement
  : BREAK
  | BREAK expression
  ;

returnStatement
  : RETURN
  | RETURN expression
  ;

timingStructure
  : PAUSE
  | STOP
  | EXIT
  ;

waitStatement
  : WAIT ON
    expression
    ( COMMA
      expression
    )*
  ;

spawnStatement
  : SPAWN
    call
  ;

packageDeclaration
  : PACKAGE IDENTIFIER
  ;

importStatement
  : IMPORT IDENTIFIER
  ;

onEachStatement
  : IDENTIFIER
  ;

onStatement
  : IDENTIFIER
  ;

literal returns [Node node]
  : NUMBER { $node = new NumberLiteral($start.getLine(), Double.parseDouble($text)); }
  | STRING { $node = new StringLiteral($start.getLine(), $text); }
  | TRUE   { $node = new TrueLiteral($start.getLine()); }
  | FALSE  { $node = new FalseLiteral($start.getLine()); }
  | NULL   { $node = new NullLiteral($start.getLine()); }
  | structure { $node = $structure.node; }
  | array     { $node = $array.node; }
  ;

structure returns [Node node]
  : ( identifierPath
    )?
    OPEN_BRACE
    ( structureAssociation
    )?
    ( (COMMA | terminator)
      structureAssociation
    )*
    COMMA*
    CLOSE_BRACE
  ;

structureAssociation returns [Object key, Node node]
  : ( IDENTIFIER { $key = $text; }
    | STRING     { $key = $text; }
    | NUMBER     { $key = Double.parseDouble($text); }
    )
    ASSIGN
    expression { $node = $expression.node; }
  ;

array returns [Node node]
  : OPEN_BRACKET
    head=expression
    ( COMMA
      tail=expression
    )*
    COMMA*
    CLOSE_BRACKET
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

CASCADE:            'cascade';
EXTERNAL:           'external';
INTERNAL:           'internal';
LOCAL:              'local';

DEFINE:             'define';
COLLECTION:         'collection';
DO:		    		      'do';
END:                'end';
IF:                 'if';
ELSE:               'else';
WHILE:              'while';
REPEAT:             'repeat';
FOREVER:            'forever';
FOR:                'for';
ON:		  		        'on';
IN:                 'in';
EACH:               'each';

SPAWN:              'spawn';

THEN:               'then';
TIMES:              'times';

RETURN:             'return';
BREAK:              'break';

IMPORT: 	          'import';
PACKAGE:	          'package';

WAIT:	              'wait';
STOP:	              'stop';
PAUSE:	            'pause';
EXIT:	              'exit';

PRINT:         	    'print';

STRING      
@init{ StringBuilder buf = new StringBuilder(); }
  : '"' 
    ( escape=ESC                       {buf.append(getText());} 
    | normal=~('"'|'\\'|'\n'|'\r')     {buf.appendCodePoint($normal);} 
    )*
    '"'                                {setText(buf.toString());}
  ;

NUMBER:             '-'? DIGIT+ ('.' DIGIT+)?;

TRUE:               'true';
FALSE:              'false';

NULL:               'null';

IDENTIFIER:         LOWER ID_CHAR*;
PARAMETER:          IDENTIFIER COLON;

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

fragment ESC
  : '\\'
    ( 'n'    {setText("\n");}
    | 'r'    {setText("\r");}
    | 't'    {setText("\t");}
    | 'b'    {setText("\b");}
    | 'f'    {setText("\f");}
    | '"'    {setText("\"");}
    | '\''   {setText("\'");}
    | '/'    {setText("/");}
    | '\\'   {setText("\\");}
    | ('u')+ i=HEX_DIGIT j=HEX_DIGIT k=HEX_DIGIT l=HEX_DIGIT { setText(Character.toString((char)Integer.parseInt("" + $i.getText() + $j.getText() + $k.getText() + $l.getText(), 16))); }
    )
  ;

fragment LETTER:    LOWER | UPPER;
fragment ID_CHAR:   LETTER | DIGIT | '_';
fragment LOWER:     'a'..'z';
fragment UPPER:     'A'..'Z';
fragment DIGIT:     '0'..'9';
fragment HEX_DIGIT: ('0'..'9'|'a'..'f'|'A'..'F');
fragment SPACE:     ' ' | '\t';

