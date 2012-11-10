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

public class JumpIfTrue extends Instruction {
	int offset;
	int inputRegister;

	public JumpIfTrue(int offset, int inputRegister) {
		this(-1, offset, inputRegister);
	}

	public JumpIfTrue(int line, int offset, int inputRegister) {
		super(line);
		this.offset = offset;
		this.inputRegister = inputRegister;
	}
}

