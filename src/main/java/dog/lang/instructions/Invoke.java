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

package dog.lang.instructions;

import dog.lang.compiler.Identifier;

import java.util.ArrayList;

public class Invoke extends Instruction {
	boolean asynchronous;
	String functionIdentifier;
	ArrayList<Integer> arguments;

	public Invoke(int outputRegister, boolean asynchronous, String functionIdentifier, ArrayList<Integer> arguments) {
		this(-1, outputRegister, asynchronous, functionIdentifier, arguments);
	}

	public Invoke(int line, int outputRegister, boolean asynchronous, String functionIdentifier, ArrayList<Integer> arguments) {
		super(line, outputRegister);
		this.asynchronous = asynchronous;
		this.functionIdentifier = functionIdentifier;
		this.arguments = arguments;
	}
}
