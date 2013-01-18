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

public class ScopeEnd extends Instruction {
	String label;
	
	public ScopeEnd(String label) {
		this.label = label;
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
