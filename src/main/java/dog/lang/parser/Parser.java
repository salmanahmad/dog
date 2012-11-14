/*
 *
 *  Copyright 2012 by Salman Ahmad (salman@salmanahmad.com).
 *  All rights reserved.
 *
 *  Permission is granted for use, copying, modification, distribution,
 *  and distribution of modified versions of this work as long as the
 *  above copyright notice is included.
 *
 */

package dog.lang.parser;

import dog.lang.nodes.*;
import dog.lang.parser.grammar.GrammarLexer;
import dog.lang.parser.grammar.GrammarParser;

import org.antlr.runtime.*;

public class Parser {
	
	public Node parse(String source) {
		ANTLRStringStream stream = new ANTLRStringStream(source);
        
        GrammarLexer lexer = new GrammarLexer(stream);
        CommonTokenStream tokens = new CommonTokenStream(lexer);
        GrammarParser parser = new GrammarParser(tokens);

        try {
			parser.eval();
        } catch(RecognitionException exception) {
        	throw new RuntimeException("Parser error.");
        }

		return null;
	}

}


