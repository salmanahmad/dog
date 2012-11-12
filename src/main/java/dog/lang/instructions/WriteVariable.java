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
	int variableRegister;

	public WriteVariable(int variableRegister, int inputRegister) {
		this(-1, inputRegister, variableRegister);
	}

	public WriteVariable(int line, int variableRegister, int inputRegister) {
		super(line, inputRegister);
		this.variableRegister = variableRegister;
	}
}
