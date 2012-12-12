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

public class Access extends Instruction {
	int valueRegister;
	int keyRegister;

	public Access(int outputRegister, int valueRegister, int keyRegister) {
		this(-1, outputRegister, valueRegister, keyRegister);
	}

	public Access(int line, int outputRegister, int valueRegister, int keyRegister) {
		super(line, outputRegister);
		this.valueRegister = valueRegister;
		this.keyRegister = keyRegister;
	}

	public String toString() {
		return String.format(":access %%r%d %%r%d %%r%d", outputRegister, valueRegister, keyRegister);
	}

	public void assemble(MethodVisitor mv, int instructionIndex, Label[] labels) {
		mv.visitLabel(labels[instructionIndex]);

		mv.visitVarInsn(ALOAD, 1);
		mv.visitFieldInsn(GETFIELD, "dog/lang/StackFrame", "registers", "[Ldog/lang/Value;");
		mv.visitLdcInsn(this.outputRegister);
		mv.visitVarInsn(ALOAD, 1);
		mv.visitFieldInsn(GETFIELD, "dog/lang/StackFrame", "registers", "[Ldog/lang/Value;");
		mv.visitLdcInsn(this.valueRegister);
		mv.visitInsn(AALOAD);
		mv.visitVarInsn(ALOAD, 1);
		mv.visitFieldInsn(GETFIELD, "dog/lang/StackFrame", "registers", "[Ldog/lang/Value;");
		mv.visitLdcInsn(this.keyRegister);
		mv.visitInsn(AALOAD);
		mv.visitMethodInsn(INVOKEVIRTUAL, "dog/lang/Value", "getValue", "()Ljava/lang/Object;");
		mv.visitMethodInsn(INVOKEVIRTUAL, "dog/lang/Value", "get", "(Ljava/lang/Object;)Ldog/lang/Value;");
		mv.visitInsn(AASTORE);

		setReturnRegister(mv, this.outputRegister);
		incrementProgramCounter(mv, instructionIndex);
	}

}
