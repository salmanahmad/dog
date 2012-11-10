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

package dog.lang.parser.nodes;

import dog.lang.compiler.Symbol;

public class Node {
	public int line;
    public String filePath;
	
	public Node parent;
	public String packageName;

	public void compile(Symbol symbol) {
		
	}
}


