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

public class LoadNumber extends Instruction {
	public double number;

	public LoadNumber(int line, int outputRegister, double number) {
		super(line, outputRegister);
		this.number = number;
	}

	public String toString() {
		return String.format(":load_number %%r%d %.2f", outputRegister, number);
	}
}

