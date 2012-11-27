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

public class Signal extends Instruction {
	public String symbol;

	public Signal (int line, String symbol) {
		super(line);
		this.symbol = symbol;
	}

	public String toString() {
		return String.format(":signal %s", symbol);
	}

	public void assemble(MethodVisitor mv, int instructionIndex, Label[] labels) {
		mv.visitLabel(labels[instructionIndex]);

		throw new RuntimeException("Assemble not implemented");

		incrementProgramCounter(mv);
	}
}
