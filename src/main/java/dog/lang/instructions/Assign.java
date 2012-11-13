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

public class Assign extends Instruction {
	int keyRegister;
	int valueRegister;

	public Assign(int outputRegister, int keyRegister, int valueRegister) {
		this(-1, outputRegister, keyRegister, valueRegister);
	}

	public Assign(int line, int outputRegister, int keyRegister, int valueRegister) {
		super(line, outputRegister);
		this.keyRegister = keyRegister;
		this.valueRegister = valueRegister;
	}

	public String toString() {
		return String.format(":assign %%r%d %%r%d %%r%d", outputRegister, keyRegister, valueRegister);
	}
}
