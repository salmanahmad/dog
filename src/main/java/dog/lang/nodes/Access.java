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
import dog.lang.compiler.Symbol;
import dog.lang.instructions.ReadVariable;
import dog.lang.instructions.WriteVariable;
import dog.lang.instructions.LoadString;
import dog.lang.instructions.LoadNumber;

import java.util.ArrayList;

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

		if(outputRegister == -1 && (scope == Identifier.Scope.CASCADE || scope == Identifier.Scope.LOCAL)) {
			if(symbol.variableGenerator.containsVariable((String)path.get(0))) {
				outputRegister = symbol.registerGenerator.generate();

				int variable = symbol.variableGenerator.getIndexForVariable((String)path.get(0));
				WriteVariable write = new WriteVariable(this.line, outputRegister, variable);
				symbol.instructions.add(write);
			}
		}

		if(outputRegister == -1 && (scope == Identifier.Scope.CASCADE || scope == Identifier.Scope.INTERNAL)) {

		}

		if(outputRegister == -1 && (scope == Identifier.Scope.CASCADE || scope == Identifier.Scope.INTERNAL)) {
			// TODO - Handle Imports
		}

		if(outputRegister == -1 && (scope == Identifier.Scope.CASCADE || scope == Identifier.Scope.EXTERNAL)) {
			
		}

		if(outputRegister == -1) {
			throw new RuntimeException("Could not resolve symbol.");
		}

		for(Object component : path) {
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



