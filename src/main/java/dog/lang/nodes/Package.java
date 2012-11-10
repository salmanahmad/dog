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
import dog.lang.instructions.Perform;

public class Package extends Node {
	String name;

	public Package(String name) {
		this(-1, name);
	}

	public Package(int line, String name) {
		super(line);
		this.name = name;
	}

	public void compile(Symbol symbol) {
		symbol.currentOutputRegister = -1;
	}
}


