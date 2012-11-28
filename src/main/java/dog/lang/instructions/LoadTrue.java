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

public class LoadTrue extends Instruction implements Opcodes {
	public LoadTrue(int line, int outputRegister) {
		super(line, outputRegister);
	}

	public String toString() {
		return String.format(":load_true %%r%d", outputRegister);
	}

	public void assemble(MethodVisitor mv, int instructionIndex, Label[] labels) {
		mv.visitLabel(labels[instructionIndex]);
		mv.visitVarInsn(ALOAD, 1);
		mv.visitFieldInsn(GETFIELD, "dog/lang/StackFrame", "registers", "[Ldog/lang/Value;");
		mv.visitIntInsn(SIPUSH, this.outputRegister);
		mv.visitTypeInsn(NEW, "dog/lang/TrueValue");
		mv.visitInsn(DUP);
		mv.visitMethodInsn(INVOKESPECIAL, "dog/lang/TrueValue", "<init>", "()V");
		mv.visitInsn(AASTORE);

		setReturnRegister(mv, this.outputRegister);
		incrementProgramCounter(mv);
	}
}

