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

public class Type extends Symbol {
	public Type(String name, Node node, Compiler compiler) {
		super(name, node, compiler);
	}

	public String toDogBytecodeString() {
		String output = "";
		output += String.format("; type: %s\n", name);
		output += String.format("; variables: %d stack:%d\n", variableGenerator.currentVariableIndex + 1, registerGenerator.largestRegister + 1);

		for(int i = 0; i < instructions.size(); i++) {
			output += String.format("%04d %s\n", i, instructions.get(i).toString());
		}

		output += "; end type\n\n\n";

		return output;
	}

	public void compile() {

	}
}
