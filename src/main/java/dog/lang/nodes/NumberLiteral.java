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

import java.util.ArrayList;

public class NumberLiteral extends Node {
	double number;

	public NumberLiteral(double number) {
		this.number = number;
	}

	public NumberLiteral(int line, double number) {
		super(line);
		this.number = number;
	}

	public void compile(Symbol symbol) {
		int outputRegister = symbol.registerGenerator.generate();

		LoadNumber instruction = new LoadNumber(this.line, outputRegister, number);
		symbol.instructions.add(instruction);

		symbol.currentOutputRegister = outputRegister;
	}

	public ArrayList<Node> children() {
		return new ArrayList<Node>();
	}
}


