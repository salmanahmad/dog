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

import java.util.ArrayList;

public class Assign extends Node {
	ArrayList<String> path;
	Node value;

	public Assign(ArrayList<String> path, Node value) {
		this(-1, path, value);
	}

	public Assign(int line, ArrayList<String> path, Node value) {
		super(line);
		this.path = path;
		this.value = value;
	}

	public void compile(Symbol symbol) {
		// TODO: I need to resolve this once scaffolding is done.
		// TODO: I need to use VariableGenerator here
	}

	public ArrayList<Node> children() {
		return new ArrayList<Node>();
	}
}




