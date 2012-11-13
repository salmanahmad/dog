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
	
	public String label;
	public int destination;

	public Throw(String label) {
		this(-1, -1, label);
	}

	public Throw(int inputRegister, String label) {
		this(-1, inputRegister, label);
	}

	public Throw(int line, int inputRegister, String label) {
		super(line);
		this.inputRegister = inputRegister;
		this.label = label;
	}

	public String toString() {
		return String.format(":throw %%r%d %%r%d %d", outputRegister, inputRegister, destination);
	}
}
