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
import dog.lang.instructions.LoadNumber;

public class NumberLiteral extends Node {
	public double number;

	public NumberLiteral(double number) {
		this.number = number;
	}

	public void compile(Symbol symbol) {
		LoadNumber instruction = new LoadNumber(this.line, symbol.registerGenerator.generate(), number);
		symbol.instructions.add(instruction);
		symbol.currentOutputRegister = instruction.outputRegister;
	}
}


