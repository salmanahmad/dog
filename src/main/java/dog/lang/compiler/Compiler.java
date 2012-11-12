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
import dog.lang.nodes.Nodes;
import dog.lang.nodes.Definition;
import dog.lang.nodes.FunctionDefinition;
import dog.lang.nodes.ConstantDefinition;
import dog.lang.nodes.StructureDefinition;

import java.util.ArrayList;

public class Compiler {
	ArrayList<Symbol> symbols = new ArrayList<Symbol>();
	
	public byte[] compile() {
		return null;
	}

	public void processNodes(Nodes ast) {
		String packageName = ast.getPackageName();
		boolean containsNonDefinitions = false;

		ArrayList<Node> nodes = Helper.descendantsOfNode(ast);

		for (Node node : nodes) {
			node.packageName = packageName;
		}

		for(Node node : ast.children()) {
			if(!(node instanceof Definition)) {
				containsNonDefinitions = true;
			}
		}

		if(containsNonDefinitions) {
			Symbol root = new Symbol(packageName + "." + "@root", ast);
			this.addSymbol(root);
		}
	}

	public void addSymbol(Symbol symbol) {
		// TODO: I also need to search the Resolver to see if there are duplicate symbols already defined...
		for(Symbol s : symbols) {
			if(s.name.equals(symbol.name)) {
				throw new RuntimeException("Duplicate symbol during compilation.");
			}
		}

		symbols.add(symbol);
	}

	public ArrayList<Symbol> searchForSymbols(String name) {
		return null;
	}
}