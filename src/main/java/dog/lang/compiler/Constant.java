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

// TODO: As of now, Constants are Deprecated. See the discussion in dog.lang.Constant.

public class Constant extends Symbol {
	public Constant(String name, Node node, Compiler compiler) {
		super(name, node, compiler);
	}
	
	public String toDogBytecodeString() {
		String output = "";
		output += String.format("; constant: %s\n", name);
		output += String.format("; variables: %d stack:%d\n", variableGenerator.currentVariableIndex + 1, registerGenerator.largestRegister + 1);

		for(int i = 0; i < instructions.size(); i++) {
			output += String.format("%04d %s\n", i, instructions.get(i).toString());
		}

		output += "; end constant\n\n\n";

		return output;
	}

	public void compile() {
		compileNodes();
	}
}