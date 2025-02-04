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
import java.util.Iterator;

public class Nodes extends Node {
    ArrayList<Node> nodes;

	public Nodes() {
    	this.nodes = new ArrayList<Node>();
    }

    public Nodes(ArrayList<Node> nodes) {
    	this.nodes = nodes;
    }

	public void compile(Symbol symbol) {

		ArrayList<Node> nodes = new ArrayList<Node>();

		if(this.nodes != null) {
			for(Iterator<Node> i = this.nodes.iterator(); i.hasNext();) {
				Node node = i.next();
				if(node != null) {
					nodes.add(node);
				}
			}
		}

		if(nodes == null || nodes.size() == 0) {
			symbol.currentOutputRegister = -1;
			return;
		}
		
		for(Iterator<Node> i = nodes.iterator(); i.hasNext();) {
			Node node = i.next();
			node.compile(symbol);
			if(i.hasNext()) {
				symbol.registerGenerator.release(symbol.currentOutputRegister);
			}
		}
	}

	public void add(Node node) {
		nodes.add(node);
	}

	public ArrayList<Node> children() {
		return nodes;
	}
}




