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

public class Instruction {
	public int line;
	public int outputRegister;

	public Instruction() {
		this.line = -1;
		this.outputRegister = -1;
	}

	public Instruction(int line) {
		this.line = line;
	}

	public Instruction(int line, int outputRegister) {
		this.line = line;
		this.outputRegister = outputRegister;
	}
}
