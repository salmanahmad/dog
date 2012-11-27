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

public class ReadConstant extends Instruction {
	String identifier;

	public ReadConstant(int outputRegister, String identifier) {
		this(-1, outputRegister, identifier);
	}

	public ReadConstant(int line, int outputRegister, String identifier) {
		super(line, outputRegister);
		this.identifier = identifier;
	}

	public String toString() {
		return String.format(":read_constant %%r%d %s", outputRegister, identifier);
	}

	public void assemble(MethodVisitor mv, int instructionIndex, Label[] labels) {
		mv.visitLabel(labels[instructionIndex]);

		throw new RuntimeException("Assemble not implemented");

		incrementProgramCounter(mv);
	}
}
