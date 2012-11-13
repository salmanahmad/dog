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

public class WriteVariable extends Instruction {
	int inputRegister;

	public WriteVariable(int outputRegister, int inputRegister) {
		this(-1, outputRegister, inputRegister);
	}

	public WriteVariable(int line, int outputRegister, int inputRegister) {
		super(line, outputRegister);
		this.inputRegister = inputRegister;
	}
}
