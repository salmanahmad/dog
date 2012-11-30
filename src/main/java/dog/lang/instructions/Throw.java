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

	public void assemble(MethodVisitor mv, int instructionIndex, Label[] labels) {
		mv.visitLabel(labels[instructionIndex]);
		
		mv.visitVarInsn(ALOAD, 1);
		mv.visitFieldInsn(GETFIELD, "dog/lang/StackFrame", "registers", "[Ldog/lang/Value;");
		mv.visitIntInsn(SIPUSH, this.outputRegister);
		if(this.inputRegister == -1) {
			mv.visitTypeInsn(NEW, "dog/lang/NullValue");
			mv.visitInsn(DUP);
			mv.visitMethodInsn(INVOKESPECIAL, "dog/lang/NullValue", "<init>", "()V");
		} else {
			mv.visitVarInsn(ALOAD, 1);
			mv.visitFieldInsn(GETFIELD, "dog/lang/StackFrame", "registers", "[Ldog/lang/Value;");
			mv.visitIntInsn(SIPUSH, this.inputRegister);
			mv.visitInsn(AALOAD);
		}
		mv.visitInsn(AASTORE);
		
		mv.visitVarInsn(ALOAD, 1);
		mv.visitLdcInsn(destination);
		mv.visitFieldInsn(PUTFIELD, "dog/lang/StackFrame", "programCounter", "I");

		mv.visitJumpInsn(GOTO, labels[destination]);
	}
}
