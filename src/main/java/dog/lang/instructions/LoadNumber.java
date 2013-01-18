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

public class LoadNumber extends Instruction implements Opcodes {
	public double number;

	public LoadNumber(int line, int outputRegister, double number) {
		super(line, outputRegister);
		this.number = number;
	}

	public String toString() {
		return String.format(":load_number %%r%d %.2f", outputRegister, number);
	}

	public void assemble(MethodVisitor mv, int instructionIndex, Label[] labels) {
		mv.visitLabel(labels[instructionIndex]);

		mv.visitVarInsn(ALOAD, 1);
		mv.visitFieldInsn(GETFIELD, "dog/lang/StackFrame", "registers", "[Ldog/lang/Value;");
		mv.visitIntInsn(SIPUSH, this.outputRegister);
		mv.visitTypeInsn(NEW, "dog/lang/NumberValue");
		mv.visitInsn(DUP);
		mv.visitLdcInsn(this.number);
		mv.visitMethodInsn(INVOKESPECIAL, "dog/lang/NumberValue", "<init>", "(D)V");
		mv.visitInsn(AASTORE);

		setReturnRegister(mv, this.outputRegister);
		incrementProgramCounter(mv, instructionIndex);
	}

}

