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
import dog.lang.instructions.Perform;

import java.util.ArrayList;
import java.util.Arrays;

public class Operation extends Node {
	Node arg1;
	Node arg2;
	String operation;

	public Operation(Node arg1, Node arg2, String operation) {
		this(-1, arg1, arg2, operation);
	}

	public Operation(int line, Node arg1, Node arg2, String operation) {
		super(line);
		this.arg1 = arg1;
		this.arg2 = arg2;
		this.operation = operation;

		setParentOfChild(arg1);
		setParentOfChild(arg2);
	}

	public void compile(Symbol symbol) {
		int register1 = -1;
		int register2 = -1;

		arg1.compile(symbol);
		register1 = symbol.currentOutputRegister;

		if(arg2 != null) {
			arg2.compile(symbol);
			register2 = symbol.currentOutputRegister;
		}

		Perform instruction = new Perform(this.line, symbol.registerGenerator.generate(), register1, register2, operation);
		symbol.instructions.add(instruction);
		symbol.currentOutputRegister = instruction.outputRegister;
	}

	public ArrayList<Node> children() {
		ArrayList<Node> output = new ArrayList<Node>();

		if(arg1 != null) {
			output.add(arg1);
		}

		if(arg2 != null) {
			output.add(arg2);
		}

		return output;
	}
}


