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

import org.apache.commons.lang3.StringUtils;

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

	public void addCompilationUnit(Nodes ast, String sourceFileName) {
		ArrayList<String> packageName = ast.getPackageName();
		ArrayList<ArrayList<String>> includedPackages = ast.getIncludedPackages();
		ArrayList<ArrayList<String>> loadedPackages = ast.getLoadedPackages();

		boolean containsNonDefinitions = false;

		ArrayList<Node> nodes = Helper.descendantsOfNode(ast);

		for (Node node : nodes) {
			node.filePath = sourceFileName;
			node.packageName = packageName;
			node.includedPackages = includedPackages;
			node.loadedPackages = loadedPackages;
		}

		for(Node node : ast.children()) {
			if(!(node instanceof Definition)) {
				containsNonDefinitions = true;
			}
		}

		if(containsNonDefinitions) {
			Symbol root = new Function(StringUtils.join(packageName, ".") + "." + "@root", ast, this);
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

	public ArrayList<dog.lang.Symbol> searchForSymbolsStartingWith(String name) {
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
		
		ArrayList<dog.lang.Symbol> resolvedList = resolver.searchForSymbolsStartingWith(name);
		list.addAll(resolvedList);

		return list;
	}

	public dog.lang.Symbol searchForSymbol(String name) {
		ArrayList<dog.lang.Symbol> symbols = searchForSymbolsStartingWith(name);
		for(dog.lang.Symbol symbol : symbols) {
			if(symbol.name.equals(name)) {
				return symbol;
			}
		}

		return null;
	}

}
