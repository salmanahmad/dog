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

public class Move extends Instruction {
	int inputRegister;

	public Move(int outputRegister, int inputRegister) {
		this(-1, outputRegister, inputRegister);
	}

	public Move(int line, int outputRegister, int inputRegister) {
		super(line);
		this.outputRegister = outputRegister;
		this.inputRegister = inputRegister;
	}

	public String toString() {
		return String.format(":move %%r%d %%r%d", outputRegister, inputRegister);
	}

	public void assemble(MethodVisitor mv, int instructionIndex, Label[] labels) {
		mv.visitLabel(labels[instructionIndex]);
		
		// TODO: if input or output register is "-1" that means that I have to replace the value with NullValue

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

		setReturnRegister(mv, this.outputRegister);
		incrementProgramCounter(mv, instructionIndex);
	}
}
