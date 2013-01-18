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

import org.objectweb.asm.*;

public class ScopeStart extends Instruction {
	public String label;
	public int returnRegister;
	public int offsetFromEnd;

	public ScopeStart(String label, int returnRegister, int offsetFromEnd) {
		this.label = label;
		this.returnRegister = returnRegister;
		this.offsetFromEnd = offsetFromEnd;
	}

	public String toString() {
		return String.format(":nop");
	}

	public void assemble(MethodVisitor mv, int instructionIndex, Label[] labels) {
		mv.visitLabel(labels[instructionIndex]);
		incrementProgramCounter(mv, instructionIndex);
		mv.visitInsn(NOP);
	}
}
