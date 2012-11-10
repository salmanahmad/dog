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

public class Return extends Instruction {
	int inputRegister;

	public Return(int inputRegister) {
		this(-1, inputRegister);
	}

	public Return(int line, int inputRegister) {
		super(line);
		this.inputRegister = inputRegister;
	}
}
