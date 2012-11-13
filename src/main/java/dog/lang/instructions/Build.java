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

public class Build extends Instruction {
	String typeIdentifier;

	public Build(int outputRegister, String typeIdentifier) {
		this(-1, outputRegister, typeIdentifier);
	}

	public Build(int line, int outputRegister, String typeIdentifier) {
		super(line, outputRegister);
		this.typeIdentifier = typeIdentifier;
	}

	public String toString() {
		return String.format(":build %%r%d '%s'", outputRegister, typeIdentifier);
	}
}
