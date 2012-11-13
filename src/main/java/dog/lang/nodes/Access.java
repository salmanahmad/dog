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
import dog.lang.compiler.Identifier;

import java.util.ArrayList;

public class Access extends Node {
	Identifier.Scope scope;
	ArrayList<Object> path;

	public Access(Identifier.Scope scope) {
		this(-1, scope);
	}

	public Access(int line, Identifier.Scope scope) {
		super(line);
		this.scope = scope;
	}

	public void compile(Symbol symbol) {
		// TODO: I need to resolve this once scaffolding is done.
		// TODO: I need to use VariableGenerator here
	}

	public ArrayList<Node> children() {
		return new ArrayList<Node>();
	}
}



