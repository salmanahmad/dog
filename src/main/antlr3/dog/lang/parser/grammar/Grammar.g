
grammar Grammar;


@parser::header { 
package dog.lang.parser.grammar;
import dog.lang.nodes.*;
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




DEFINE:             'define';
DO:		    'do';
END:                'end';
IF:                 'if';
ELSE:               'else';
WHILE:              'while';
REPEAT:             'repeat';
FOREVER:            'forever';
FOR:                'for';
ON:		    'on';
EACH:               'each';

IMPORT: 	    'import';
PACKAGE:	    'package';

WAIT:	            'wait';
STOP:	            'stop';
PAUSE:	            'pause';
EXIT:	            'exit';

PRINT:         	    'print';

NULL:               'null';
TRUE:               'true';
FALSE:              'false';

STRING:             '"' ~('\\' | '"')* '"';
NUMBER:             '-'? DIGIT+ '.' DIGIT+;

COLON:              ':';
SEMICOLON:          ';';
DOT:                '.';
COMMA:              ',';

OPEN_BRACKET:       '[';
CLOSE_BRACKET:      ']';
OPEN_PAREN:         '(';
CLOSE_PAREN:        ')';
OPEN_BRACE:         '{';
CLOSE_BRACE:        '{';

ASSIGN:             '=';
EQUAL:              '==';
NOT_EQUAL:	    '!=';
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
