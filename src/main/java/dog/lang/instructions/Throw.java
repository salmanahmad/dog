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

public class Throw extends Instruction {
	int inputRegister;
	String symbol;

	public Throw(String symbol) {
		this(-1, -1, symbol);
	}

	public Throw(int inputRegister, String symbol) {
		this(-1, inputRegister, symbol);
	}

	public Throw(int line, int inputRegister, String symbol) {
		super(line);
		this.inputRegister = inputRegister;
		this.symbol = symbol;
	}
}
