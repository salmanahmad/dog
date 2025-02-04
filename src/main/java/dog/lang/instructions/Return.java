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

public class Return extends Instruction {
	int inputRegister;

	public Return(int inputRegister) {
		this(-1, inputRegister);
	}

	public Return(int line, int inputRegister) {
		super(line);
		this.inputRegister = inputRegister;
	}

	public String toString() {
		return String.format(":return %%r%d", inputRegister);
	}

	public void assemble(MethodVisitor mv, int instructionIndex, Label[] labels) {
		mv.visitLabel(labels[instructionIndex]);

		setReturnRegister(mv, this.inputRegister);
		incrementProgramCounter(mv, instructionIndex);

		mv.visitTypeInsn(NEW, "dog/lang/Signal");
		mv.visitInsn(DUP);
		mv.visitFieldInsn(GETSTATIC, "dog/lang/Signal$Type", "RETURN", "Ldog/lang/Signal$Type;");
		mv.visitMethodInsn(INVOKESPECIAL, "dog/lang/Signal", "<init>", "(Ldog/lang/Signal$Type;)V");
		mv.visitInsn(ARETURN);
	}
}
