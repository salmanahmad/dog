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

package dog.lang.nodes;

import dog.lang.compiler.Symbol;

import java.util.Arrays;
import java.util.ArrayList;

public class FunctionDefinition extends Definition {
	ArrayList<String> arguments;
	Node body;

	public FunctionDefinition(String name, ArrayList<String> arguments, Node body) {
		this(-1, name, arguments, body);
	}

	public FunctionDefinition(int line, String name, ArrayList<String> arguments, Node body) {
		super(line, name);
		this.arguments = arguments;
		this.body = body;
	}

	public void compile(Symbol symbol) {
		if(symbol.name.equals(this.fullyQualifiedName())) {
			for(String argument : arguments) {
				symbol.variableGenerator.registerVariable(argument);
			}

			body.compile(symbol);
		} else {
			// TODO: I should consider returning a FunctionPointer type that will
			// be assignable to the caller code. Useful for inner functions
			symbol.currentOutputRegister = -1;
		}
	}

	public ArrayList<Node> children() {
		return new ArrayList<Node>(Arrays.asList(body));
	}
}
