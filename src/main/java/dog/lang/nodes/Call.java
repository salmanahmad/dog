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
import dog.lang.instructions.Invoke;

import java.util.ArrayList;

import org.apache.commons.lang3.StringUtils;

public class Call extends Node {
	boolean asynchronous;
	Identifier function;
	ArrayList<Node> arguments;

	public Call(boolean asynchronous, Identifier function, ArrayList<Node> arguments) {
		this(-1, asynchronous, function, arguments);
	}

	public Call(int line, boolean asynchronous, Identifier function, ArrayList<Node> arguments) {
		super(line);
		this.asynchronous = asynchronous;
		this.function = function;
		this.arguments = arguments;
	}

	public void compile(Symbol symbol) {
		ArrayList<Integer> argumentRegisters = new ArrayList<Integer>();
		String functionIdentifier;

		for(Node argument: arguments) {
			argument.compile(symbol);
			argumentRegisters.add(symbol.currentOutputRegister);
		}

		int outputRegister = symbol.registerGenerator.generate();

		if(function.scope == Identifier.Scope.EXTERNAL) {
			functionIdentifier = StringUtils.join(function.path, ".");
		} else {
			functionIdentifier = this.packageName + "." + StringUtils.join(function.path, ".");
		}

		if(symbol.getCompiler().searchForSymbols(functionIdentifier).size() != 1) {
			throw new RuntimeException("Unable to unique identify the function symbol.");
		}

		Invoke invocation = new Invoke(this.line, outputRegister, asynchronous, functionIdentifier, argumentRegisters);
		symbol.instructions.add(invocation);

		for(int register : argumentRegisters) {
			symbol.registerGenerator.release(register);
		}

		symbol.currentOutputRegister = outputRegister;
	}

	public ArrayList<Node> children() {
		return arguments;
	}
}



