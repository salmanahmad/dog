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

package dog.lang.compiler;

import dog.lang.nodes.Node;

import java.util.ArrayList;

public class Helper {
	public static ArrayList<Node> descendantsOfNode(Node node) {
		ArrayList<Node> descendants = new ArrayList<Node>();
		descendants.addAll(node.children());
		for(Node child : node.children()) {
			descendants.addAll(descendantsOfNode(child));
		}

		return descendants;
	}
}