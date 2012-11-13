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

	public JumpIfTrue(int inputRegister, int offset) {
		this(-1, offset, inputRegister);
	}

	public JumpIfTrue(int line, int inputRegister, int offset) {
		super(line);
		this.offset = offset;
		this.inputRegister = inputRegister;
	}

	public String toString() {
		return String.format(":jump_if_true %%r%d %d", inputRegister, offset);
	}
}

