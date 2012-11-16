
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

@parser::members {
    // TODO - Better error reporting here --- http://www.antlr.org/wiki/display/ANTLR3/Error+reporting+and+recovery
    public void emitErrorMessage(String message) {
        throw new RuntimeException(message);
    }
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
  : literal                   { $node = $literal.node; }
  | OPEN_PAREN expression CLOSE_PAREN   { $node = $expression.node; }
  | access                    { $node = $access.node; }
  | call                      { $node = $call.node; }
  | functionDefinition        { $node = $functionDefinition.node; }
  | structureDefinition       { $node = $structureDefinition.node; }
  | collectionDefinition      { $node = $collectionDefinition.node; }
  | controlStructure          { $node = $controlStructure.node; }
  | timingStructure           { $node = $timingStructure.node; }
  | waitStatement             { $node = $waitStatement.node; }
  | spawnStatement            { $node = $spawnStatement.node; }
  | packageDeclaration        { $node = $packageDeclaration.node; }
  | importStatement           { $node = $importStatement.node; }
  | onEachStatement           { $node = $onEachStatement.node; }
  | onStatement               { $node = $onStatement.node; }
  ;

assignment returns [Node node]
@init{ ArrayList<Object> path = new ArrayList<Object>(); }
  : IDENTIFIER      { path.add($IDENTIFIER.text); }
    ( accessPath    { path.addAll($accessPath.path); }
    )?
    ASSIGN 
    expression      { $node = new Assign($start.getLine(), path, $expression.node); }
  ;

access returns [Node node]
@init{ Identifier.Scope scope = Identifier.Scope.CASCADE; ArrayList<Object> path = new ArrayList<Object>(); }
  :                                        
    ( literal                             { path.add($literal.node); } 
    | identifierPath                      { path.add($identifierPath.identifier.path); scope = $identifierPath.identifier.scope; } 
    )
    ( accessPath                          { path.addAll($accessPath.path); }
    )?                                    { $node = new Access($start.getLine(), scope, path); }
  ;

accessPath returns [ArrayList<Object> path]
  : accessDot         { $path = $accessDot.path; }
  | accessBracket     { $path = $accessBracket.path; }
  ;

accessDot returns [ArrayList<Object> path]
  : DOT               { $path = new ArrayList<Object>(); }
    IDENTIFIER        { $path.add($text); }
    ( accessPath      { $path.addAll($accessPath.path); }
    )?
  ;

accessBracket returns [ArrayList<Object> path]
  : OPEN_BRACKET      { $path = new ArrayList<Object>(); }
    expression        { $path.add($expression.node); }
    CLOSE_BRACKET
    ( accessPath      { $path.addAll($accessPath.path); }
    )?
  ;

identifierPath returns [Identifier identifier]
  :               { $identifier =  new Identifier(); }
                  { $identifier.scope = Identifier.Scope.CASCADE; }
    ( CASCADE     { $identifier.scope = Identifier.Scope.CASCADE; }
    | EXTERNAL    { $identifier.scope = Identifier.Scope.EXTERNAL; }
    | INTERNAL    { $identifier.scope = Identifier.Scope.INTERNAL; }
    | LOCAL       { $identifier.scope = Identifier.Scope.LOCAL; }
    )?              
    head=IDENTIFIER    { $identifier.path.add($head.getText()); }
    ( DOT
      tail=IDENTIFIER  { $identifier.path.add($tail.getText()); }
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

collectionDefinition returns [Node node]
  : DEFINE
    COLLECTION
    IDENTIFIER
  ;

controlStructure returns [Node node]
  : ifStatement
  | forLoop
  | whileLoop
  | repeatLoop
  | foreverLoop
  | breakStatement
  | returnStatement
  ;

ifStatement returns [Node node]
  : IF 
    expression
    (THEN | DO) terminator?
    ( elseIfStatement
    )*
    ( elseStatement
    )?
    END
  ;

elseIfStatement returns [Node node]
  : ELSE 
    IF
    expression
    (THEN | DO) terminator?
    ( expressions
    )?
  ;

elseStatement returns [Node node]
  : ELSE
    ( expressions
    )?
  ;


forLoop returns [Node node]
  : FOR EACH
    IDENTIFIER
    IN
    expression
    DO terminator?
    ( expressions
    )?
    END
  ;

whileLoop returns [Node node]
  : WHILE
    expression
    DO terminator?
    ( expressions
    )?
    END
  ;

repeatLoop returns [Node node]
  : REPEAT
    expression
    (TIMES | DO) terminator?
    ( expressions
    )?
    END
  ;

foreverLoop returns [Node node]
  : FOREVER DO
    ( expressions
    )?
    END
  ;

breakStatement returns [Node node]
  : BREAK
  | BREAK expression
  ;

returnStatement returns [Node node]
  : RETURN
  | RETURN expression
  ;

timingStructure returns [Node node]
  : PAUSE
  | STOP
  | EXIT
  ;

waitStatement returns [Node node]
  : WAIT ON
    expression
    ( COMMA
      expression
    )*
  ;

spawnStatement returns [Node node]
  : SPAWN
    call
  ;

packageDeclaration returns [Node node]
  : PACKAGE IDENTIFIER
  ;

importStatement returns [Node node]
  : IMPORT IDENTIFIER
  ;

onEachStatement returns [Node node]
  : IDENTIFIER
  ;

onStatement returns [Node node]
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
  | '\''
    ( normal=~('\'')                   {buf.appendCodePoint($normal);} 
    )*
    '\''                               {setText(buf.toString());}
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

