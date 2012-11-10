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

public abstract class Node {
	public int line;

    public String filePath;
	public String packageName;

	public Node parent;
	
	public Node() {
		this.line = -1;
	}

	public Node(int line) {
		this.line = line;
	}

	public abstract void compile(Symbol symbol);
	//public abstract ArrayList<Node> children();
}


