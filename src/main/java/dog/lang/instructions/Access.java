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

public class Access extends Instruction {
	int valueRegister;
	int keyRegister;

	public Access(int outputRegister, int valueRegister, int keyRegister) {
		this(-1, outputRegister, valueRegister, keyRegister);
	}

	public Access(int line, int outputRegister, int valueRegister, int keyRegister) {
		super(line, outputRegister);
		this.valueRegister = valueRegister;
		this.keyRegister = keyRegister;
	}
}
