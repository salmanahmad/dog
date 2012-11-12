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
import dog.lang.compiler.Compiler;

import java.util.ArrayList;

public abstract class Definition extends Node {
	String name;

	public Definition(String name) {
		this(-1, name);
	}

	public Definition(int line, String name) {
		super(line);
		this.name = name;
	}

	public void scaffold(Compiler compiler) {
		Symbol symbol = new Symbol(this.fullyQualifiedName(), this);
		compiler.addSymbol(symbol);
		super.scaffold(compiler);
	}

	// TODO: This currently does not work with nested functions because the fullyQualified name
	// does not look into Symbol that it is defined in. How do I fix that?
	public String fullyQualifiedName() {
		return this.packageName + "." + this.name;
	}
}
