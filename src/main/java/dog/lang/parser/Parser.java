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
	
	public Nodes parse(String source) {
		Nodes nodes = null;

        ANTLRStringStream stream = new ANTLRStringStream(source);
        GrammarLexer lexer = new GrammarLexer(stream);

        // Token token;
        // while (null != (token = lexer.nextToken())) {
        //     int tokenType = token.getType();
        //     if (tokenType == -1) break;
        //     if (token.getChannel() == Token.DEFAULT_CHANNEL)
        //     System.out.println(GrammarParser.tokenNames[token.getType()]);
        // }
        // lexer.reset();

        CommonTokenStream tokens = new CommonTokenStream(lexer);
        GrammarParser parser = new GrammarParser(tokens);

        try {
            nodes = parser.program().nodes;
        } catch(RecognitionException exception) {
        	throw new RuntimeException("Parser error.");
        }

		return nodes;
	}

    public GrammarParser parser(String source) {
        ANTLRStringStream stream = new ANTLRStringStream(source);
        GrammarLexer lexer = new GrammarLexer(stream);
        CommonTokenStream tokens = new CommonTokenStream(lexer);
        GrammarParser parser = new GrammarParser(tokens);

        return parser;
    }

}


