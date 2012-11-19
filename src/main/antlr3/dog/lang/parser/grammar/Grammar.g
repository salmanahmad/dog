
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
import java.util.Arrays;

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
  : n1=andExpression      { $node = $n1.node; }
    ( OR
      n2=orExpression     { $node = new Operation($start.getLine(), $n1.node, $n2.node, "||"); }
    )?
  ;

andExpression returns [Node node]
  : n1=relationalExpression { $node = $n1.node; }
    ( AND
      n2=andExpression      { $node = new Operation($start.getLine(), $n1.node, $n2.node, "&&"); }
    )?
  ;

relationalExpression returns [Node node]
  : n1=additiveExpression     { $node = $n1.node; }
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
  : NOT node1=unaryExpresion      { $node = new Operation($start.getLine(), $node1.node, null, "!"); }
  | primaryExpression             { $node = $primaryExpression.node; }
  ;

primaryExpression returns [Node node]
  : literal                   { $node = $literal.node; }
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
    | OPEN_PAREN expression CLOSE_PAREN   { $node = $expression.node; }
    | identifierPath                      { path.addAll($identifierPath.identifier.path); scope = $identifierPath.identifier.scope; } 
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
  :                    { $identifier =  new Identifier(); }
                       { $identifier.scope = Identifier.Scope.CASCADE; }
    ( CASCADE          { $identifier.scope = Identifier.Scope.CASCADE; }
    | EXTERNAL         { $identifier.scope = Identifier.Scope.EXTERNAL; }
    | INTERNAL         { $identifier.scope = Identifier.Scope.INTERNAL; }
    | LOCAL            { $identifier.scope = Identifier.Scope.LOCAL; }
    )?              
    head=IDENTIFIER    { $identifier.path.add($head.getText()); }
    ( DOT
      tail=IDENTIFIER  { $identifier.path.add($tail.getText()); }
    )*              
  ;

call returns [Node node]
@init { ArrayList<Node> arguments = new ArrayList<Node>(); Identifier path = new Identifier(); String name = ""; }
  : ( identifierPath             { path = $identifierPath.identifier; }
    )?
    headParam=PARAMETER          { name += $headParam.getText(); }
    head=expression              { arguments.add($head.node); }
    ( tailParam=PARAMETER        { name += $tailParam.getText(); }
      tail=expression            { arguments.add($tail.node); }
    )*                           { path.path.add(name); $node = new Call($start.getLine(), false, path, arguments); }
  ;

spawnStatement returns [Node node]
  : SPAWN
    call                    {$node = $call.node; ((Call)$node).setAsynchronous(true); }
  ;

functionDefinition returns [Node node]
  : functionWithArguments        { $node = $functionWithArguments.node; }
  | functionWithoutArguments     { $node = $functionWithoutArguments.node; }
  ;

functionWithArguments returns [Node node]
@init { String name = ""; ArrayList<String> args = new ArrayList<String>(); Node body = new Nodes(); }
  : DEFINE                       
    headParam=PARAMETER          { name += $headParam.getText(); }
    headId=IDENTIFIER            { args.add($headId.getText()); }
    ( tailParam=PARAMETER        { name += $tailParam.getText(); }
      tailId=IDENTIFIER          { args.add($tailId.getText()); }
    )*
    DO terminator? 
    ( expressions                { body = $expressions.nodes; }
    )?
    END                          { $node = new FunctionDefinition($start.getLine(), name, args, body); }
  ;

functionWithoutArguments returns [Node node]
@init { String name = ""; ArrayList<String> args = new ArrayList<String>(); Node body = new Nodes(); }
  : DEFINE
    IDENTIFIER                   { name += $IDENTIFIER.text; }
    DO terminator?
    ( expressions                { body = $expressions.nodes; }
    )?
    END                          { $node = new FunctionDefinition($start.getLine(), name, args, body); }
  ;

structureDefinition returns [Node node]
@init { String name = ""; HashMap<Object, Node> properties = new HashMap<Object, Node>(); }
  : DEFINE
    IDENTIFIER                        { name = $IDENTIFIER.text; }
    NEWLINE* OPEN_BRACE NEWLINE*
    ( terminator?
      head=structureAssociation       { properties.put($head.key, $head.node); }
      ( (COMMA | terminator)
        tail=structureAssociation     { properties.put($tail.key, $tail.node); }
      )*
    )?
    NEWLINE* CLOSE_BRACE              { $node = new StructureDefinition($start.getLine(), name, properties); }
  ;

collectionDefinition returns [Node node]
// TODO: Once I add the native language integration I need to create the package type
// and subclass it here...
  : DEFINE
    COLLECTION
    IDENTIFIER 
  ;

controlStructure returns [Node node]
  : ifStatement           { $node = $ifStatement.node; }
  | forLoop               { $node = $forLoop.node; }  
  | whileLoop             { $node = $whileLoop.node; }  
  | repeatLoop            { $node = $repeatLoop.node; } 
  | foreverLoop           { $node = $foreverLoop.node; }  
  | breakStatement        { $node = $breakStatement.node; }   
  | returnStatement       { $node = $returnStatement.node; }    
  ;

ifStatement returns [Node node]
@init { 
  Node condition = null; 
  Nodes trueBranch = null; 
  Nodes falseBranch = null; 
  Nodes falseBranchPointer = null; 
  Nodes temp = null;  
}
  : IF 
    expression                { condition = $expression.node; }
    (THEN | DO) terminator?
    ( expressions             { trueBranch = $expressions.nodes; }
    )?
    ( elseIfStatement         { if(falseBranch == null) { falseBranch = new Nodes(); falseBranchPointer = falseBranch; } }
                              { temp = new Nodes(); }
                              { falseBranchPointer.add(new Branch($elseIfStatement.condition, $elseIfStatement.nodes, temp)); }
                              { falseBranchPointer = temp; }
    )*
    ( elseStatement           { if(falseBranch == null) { falseBranch = new Nodes(); falseBranchPointer = falseBranch; } }
                              { falseBranchPointer.add($elseStatement.nodes);  }
    )?
    END                       { $node = new Branch($start.getLine(), condition, trueBranch, falseBranch); }
  ;

elseIfStatement returns [Node condition, Nodes nodes]
  : ELSE 
    IF                          { $nodes = null; }
    expression                  { $condition = $expression.node; }
    (THEN | DO) terminator?
    ( expressions               { $nodes = $expressions.nodes; }
    )?
  ;

elseStatement returns [Nodes nodes]
  : ELSE terminator?
    ( expressions               { $nodes = $expressions.nodes; }
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
  : FOREVER DO terminator?
    ( expressions
    )?
    END
  ;

breakStatement returns [Node node]
  : BREAK expression        { $node = new Break($start.getLine(), $expression.node); }
  | BREAK                   { $node = new Break($start.getLine(), null); }
  ;

returnStatement returns [Node node]
  : RETURN expression       { $node = new Return($start.getLine(), $expression.node); }
  | RETURN                  { $node = new Return($start.getLine(), null); }
  ;

timingStructure returns [Node node]
  : PAUSE                   { $node = new Pause($start.getLine()); }
  | STOP                    { $node = new Stop($start.getLine()); }
  | EXIT                    { $node = new Exit($start.getLine()); }
  ;

waitStatement returns [Node node]
  : WAIT ON
    expression
    ( COMMA
      expression
    )*
  ;

onEachStatement returns [Node node]
  : ON EACH
    IDENTIFIER
    ( IN
      expression
    )?
    DO terminator?
    ( expressions
    )?
    END
  ;

onStatement returns [Node node]
  : ON
    IDENTIFIER
    ( IN
      expression
    )?
    DO terminator?
    ( expressions
    )?
    ( elseOnStatement
    )*
    END
  ;

elseOnStatement returns [Node node]
  : ELSE ON
    IDENTIFIER
    ( IN
      expression
    )?
    DO terminator?
    ( expressions
    )?
  ;

packageDeclaration returns [Node node]
  : PACKAGE IDENTIFIER  { $node = new dog.lang.nodes.Package($start.getLine(), $IDENTIFIER.text); }
  ;

importStatement returns [Node node]
  : IMPORT IDENTIFIER   { $node = new Import($start.getLine(), $IDENTIFIER.text); }
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
@init { Identifier type = null;  HashMap<Object, Node> value = new HashMap<Object, Node>(); }
  : ( identifierPath          { type = $identifierPath.identifier; }
    )?
    OPEN_BRACE
    ( head=structureAssociation    { value.put($head.key, $head.node); }
    )?
    ( (COMMA | NEWLINE)+
      tail=structureAssociation    { value.put($tail.key, $tail.node); }
    )*
    (COMMA | NEWLINE)*
    CLOSE_BRACE                    { $node = new StructureLiteral($start.getLine(), type, value); }
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
@init { 
    HashMap<Object, Node> value = new HashMap<Object, Node>(); 
    double index = 0; 
    Identifier type = new Identifier(Identifier.Scope.EXTERNAL, new ArrayList<String>(Arrays.asList("dog", "array")));
}
  : OPEN_BRACKET
    ( head=expression       { value.put(index, $head.node); index++; }
    )?
    ( (COMMA | NEWLINE)+
      tail=expression       { value.put(index, $tail.node); index++; }
    )*
    (COMMA | NEWLINE)*
    CLOSE_BRACKET           { $node = new StructureLiteral($start.getLine(), type, value);  }
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
  : COMMENT
  | (NEWLINE | SEMICOLON)+
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

AND:                '&&' | 'and';
OR:                 '||' | 'or';
NOT:                '!' | 'not';

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

