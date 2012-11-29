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

import dog.lang.Bark;
import dog.lang.Resolver;
import dog.lang.nodes.Node;
import dog.lang.nodes.Nodes;
import dog.lang.nodes.Definition;
import dog.lang.nodes.FunctionDefinition;
import dog.lang.nodes.ConstantDefinition;
import dog.lang.nodes.StructureDefinition;

import java.util.ArrayList;

public class Compiler {
	ArrayList<Symbol> symbols = new ArrayList<Symbol>();
	Resolver resolver;
	Bark bark;

	public Compiler() {
		this(new Resolver());
	}

	public Compiler(Resolver r) {
		resolver = r;
	}

	public ArrayList<Symbol> getSymbols() {
		return symbols;
	}

	public Bark getBark() {
		return bark;
	}

	public Bark compile() {
		ArrayList<byte[]> bytecode = new ArrayList<byte[]>();

		for(Symbol symbol : symbols) {
			symbol.compile();
		}

		for(Symbol symbol : symbols) {
			bytecode.add(symbol.bytecode);
		}

		bark = new Bark(symbols.get(0).name, bytecode);
		return bark;
	}

	// TODO: Rename to addCompilationUnit
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
			Symbol root = new Function(packageName + "." + "@root", ast, this);
			this.addSymbol(root);
		}

		ast.scaffold(this);
	}

	public void addSymbol(Symbol symbol) {
		for(Symbol s : symbols) {
			if(s.name.equals(symbol.name)) {
				throw new RuntimeException("Duplicate symbol during compilation.");
			}
		}

		symbols.add(symbol);
	}

	public ArrayList<dog.lang.Symbol> searchForSymbols(String name) {
		ArrayList<dog.lang.Symbol> list = new ArrayList<dog.lang.Symbol>();
		for(Symbol symbol : symbols) {
			if(symbol.name.startsWith(name)) {
				if(symbol instanceof Constant) {
					list.add(new dog.lang.Symbol(symbol.name, dog.lang.Symbol.Kind.CONSTANT));
				}

				if(symbol instanceof Type) {
					list.add(new dog.lang.Symbol(symbol.name, dog.lang.Symbol.Kind.TYPE));
				}

				if(symbol instanceof Function) {
					list.add(new dog.lang.Symbol(symbol.name, dog.lang.Symbol.Kind.FUNCTION));
				}
			}
		}
		
		ArrayList<dog.lang.Symbol> resolvedList = resolver.searchForSymbols(name);
		list.addAll(resolvedList);

		return list;
	}
}