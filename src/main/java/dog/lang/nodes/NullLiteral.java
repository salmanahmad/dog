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
import dog.lang.instructions.LoadNull;

import java.util.ArrayList;

public class NullLiteral extends Node {

	public NullLiteral(int line) {
		super(line);
	}

	public void compile(Symbol symbol) {
		int outputRegister = symbol.registerGenerator.generate();

		LoadNull instruction = new LoadNull(this.line, outputRegister);
		symbol.instructions.add(instruction);

		symbol.currentOutputRegister = outputRegister;
	}

	public ArrayList<Node> children() {
		return new ArrayList<Node>();
	}
}

