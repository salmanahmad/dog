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
import dog.lang.compiler.Constant;
import dog.lang.compiler.Function;
import dog.lang.compiler.Type;
import dog.lang.instructions.ReadVariable;
import dog.lang.instructions.WriteVariable;
import dog.lang.instructions.LoadString;
import dog.lang.instructions.LoadNumber;

import java.util.List;
import java.util.ArrayList;

import org.apache.commons.lang3.StringUtils;

public class Access extends Node {
	Identifier.Scope scope;
	ArrayList<Object> path;

	public Access(Identifier.Scope scope, ArrayList<Object> path) {
		this(-1, scope, path);
	}

	public Access(int line, Identifier.Scope scope, ArrayList<Object> path) {
		super(line);
		this.scope = scope;
		this.path = path;
	}

	public void compile(Symbol symbol) {
		int outputRegister = -1;
		int componentRegister = -1;
		List<Object> remainingPath = null;

		if(outputRegister == -1 && (scope == Identifier.Scope.CASCADE || scope == Identifier.Scope.LOCAL)) {
			if(symbol.variableGenerator.containsVariable((String)path.get(0))) {
				outputRegister = symbol.registerGenerator.generate();

				int variable = symbol.variableGenerator.getIndexForVariable((String)path.get(0));
				WriteVariable write = new WriteVariable(this.line, outputRegister, variable);
				symbol.instructions.add(write);
			}
		}

		if(outputRegister == -1 && (scope == Identifier.Scope.CASCADE || scope == Identifier.Scope.INTERNAL)) {
			ArrayList<String> prefix = new ArrayList<String>();

			for (int i = 0; i < path.size(); i++) {
				Object component = path.get(i);
				if(component instanceof String) {
					prefix.add((String)component);
				} else {
					break;
				}
			}

			for(int i = 1; i <= prefix.size(); i++) {
				String symbolIdentifier = this.packageName + "." + StringUtils.join(prefix.subList(0, i).toArray(), ".");
				ArrayList<Symbol> symbols = symbol.getCompiler().searchForSymbols(symbolIdentifier);
				if(symbols.size() == 0) {
					break;
				} else if(symbols.size() == 1) {
					if(symbols.get(0) instanceof Constant) {

					} else if(symbols.get(0) instanceof Type) {

					} else if(symbols.get(0) instanceof Function) {

					}
					
					try {
						remainingPath = path.subList(i + 1, path.size());
					} catch(IndexOutOfBoundsException e) {
						remainingPath = new ArrayList<Object>();
					}
				}
			}
		}

		if(outputRegister == -1 && (scope == Identifier.Scope.CASCADE || scope == Identifier.Scope.INTERNAL)) {
			// TODO - Handle Imports
		}

		if(outputRegister == -1 && (scope == Identifier.Scope.CASCADE || scope == Identifier.Scope.EXTERNAL)) {
			// TODO...
		}

		if(outputRegister == -1) {
			throw new RuntimeException("Could not resolve symbol.");
		}

		for(Object component : remainingPath) {
			if(component instanceof Number) {
				componentRegister = symbol.registerGenerator.generate();
				LoadNumber load = new LoadNumber(this.line, componentRegister, ((Number)component).doubleValue());
				symbol.instructions.add(load);
			} else if(component instanceof String) {
				componentRegister = symbol.registerGenerator.generate();
				LoadString load = new LoadString(this.line, componentRegister, (String)component);
				symbol.instructions.add(load);
			} else if(component instanceof Node) {
				((Node)component).compile(symbol);
				componentRegister = symbol.currentOutputRegister;
			} else {
				throw new RuntimeException("Invalid assign path during compilation");
			}

			dog.lang.instructions.Access access = new dog.lang.instructions.Access(this.line, outputRegister, outputRegister, componentRegister);
			symbol.instructions.add(access);

			symbol.registerGenerator.release(componentRegister);
		}

		symbol.currentOutputRegister = outputRegister;
	}

	public ArrayList<Node> children() {
		return new ArrayList<Node>();
	}
}



