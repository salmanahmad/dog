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

public class Perform extends Instruction {
	public int inputRegister1;
	public int inputRegister2;

	public String operation;

	public Perform(int outputRegister, int inputRegister1, int inputRegister2, String operation) {
		this(-1, outputRegister, inputRegister1, inputRegister2, operation);
	}

	public Perform(int line, int outputRegister, int inputRegister1, int inputRegister2, String operation) {
		super(line, outputRegister);
		this.inputRegister1 = inputRegister1;
		this.inputRegister2 = inputRegister2;
		this.operation = operation;
	}

	public String toString() {
		return String.format(":perform %%r%d %%r%d %%r%d %s", outputRegister, inputRegister1, inputRegister2, operation);
	}
}

