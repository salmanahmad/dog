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
import dog.lang.instructions.LoadString;

import java.util.ArrayList;
import java.util.HashMap;

public class StructureLiteral extends Node {
	Identifier type;
	HashMap<Object, Node> value;

	public StructureLiteral(HashMap<Object, Node> value) {
		this(null, value);
	}

	public StructureLiteral(Identifier type, HashMap<Object, Node> value) {
		this(-1, type, value);
	}

	public StructureLiteral(int line, Identifier type, HashMap<Object, Node> value) {
		super(line);
		this.type = type;
		this.value = value;	
	}

	public void compile(Symbol symbol) {
		if(type != null) {

		}
	}

	public ArrayList<Node> children() {
		return new ArrayList<Node>(value.values());
	}
}



