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

import dog.lang.compiler.Function;
import dog.lang.compiler.Symbol;
import dog.lang.compiler.Scope;
import dog.lang.instructions.LoadNull;
import dog.lang.instructions.Jump;

import java.util.ArrayList;

public class Loop extends Node {
	Node body;

	public Loop(Node body) {
		this(-1, body);
	}

	public Loop(int line, Node body) {
		super(line);
		this.body = body;
	}

	public void compile(Symbol symbol) {
		if(this.body == null) {
			symbol.currentOutputRegister = -1;
		} else {
			int outputRegister = symbol.registerGenerator.generate();
			LoadNull output = new LoadNull(this.line, outputRegister);
			symbol.instructions.add(output);

			Symbol nested = symbol.nestedSymbol();
			body.compile(nested);
			int nestedRegister = nested.currentOutputRegister;

			Jump jumpToStart = new Jump(this.line, 0 - nested.instructions.size());

			symbol.instructions.addAll(nested.instructions);
			symbol.instructions.add(jumpToStart);

			Scope scope = new Scope();
			scope.start = (symbol.instructions.size() - 1) - (nested.instructions.size() + 1);
			scope.end = symbol.instructions.size() - 1;
			scope.label = "break";
			scope.offsetFromEnd = 1;
			scope.returnRegister = outputRegister;
			symbol.scopes.add(scope);

			symbol.registerGenerator.release(nestedRegister);
			
			symbol.currentOutputRegister = outputRegister;
		}
	}

	public ArrayList<Node> children() {
		return new ArrayList<Node>();
	}
}



