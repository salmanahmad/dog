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

public class StructureDefinition extends Definition {
	public void compile(Symbol symbol) {
		if(symbol.name.equals(this.fullyQualifiedName())) {
			
		}
	}

	public ArrayList<Node> children() {
		return new ArrayList<Node>();
	}
}
