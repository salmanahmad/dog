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
import dog.lang.instructions.Perform;

import java.util.ArrayList;

public class Package extends Node {
	ArrayList<String> identifier;

	public Package(ArrayList<String> identifier) {
		this(-1, identifier);
	}

	public Package(int line, ArrayList<String> identifier) {
		super(line);
		this.identifier = identifier;
	}

	public void compile(Symbol symbol) {
		symbol.currentOutputRegister = -1;
	}

	public ArrayList<String> getPackageName() {
		return identifier;
	}

	public ArrayList<Node> children() {
		return new ArrayList<Node>();
	}
}


