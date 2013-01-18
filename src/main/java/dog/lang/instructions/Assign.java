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

public class Assign extends Instruction {
	int keyRegister;
	int valueRegister;

	public Assign(int outputRegister, int keyRegister, int valueRegister) {
		this(-1, outputRegister, keyRegister, valueRegister);
	}

	public Assign(int line, int outputRegister, int keyRegister, int valueRegister) {
		super(line, outputRegister);
		this.keyRegister = keyRegister;
		this.valueRegister = valueRegister;
	}

	public String toString() {
		return String.format(":assign %%r%d %%r%d %%r%d", outputRegister, keyRegister, valueRegister);
	}

	public void assemble(MethodVisitor mv, int instructionIndex, Label[] labels) {
		mv.visitLabel(labels[instructionIndex]);

		mv.visitVarInsn(ALOAD, 1);
		mv.visitFieldInsn(GETFIELD, "dog/lang/StackFrame", "registers", "[Ldog/lang/Value;");
		mv.visitLdcInsn(this.outputRegister);
		mv.visitInsn(AALOAD);
		mv.visitVarInsn(ALOAD, 1);
		mv.visitFieldInsn(GETFIELD, "dog/lang/StackFrame", "registers", "[Ldog/lang/Value;");
		mv.visitLdcInsn(this.keyRegister);
		mv.visitInsn(AALOAD);
		mv.visitLdcInsn(this.keyRegister);
		mv.visitMethodInsn(INVOKEVIRTUAL, "dog/lang/Value", "getValue", "(I)Ljava/lang/Object;");
		mv.visitVarInsn(ALOAD, 1);
		mv.visitFieldInsn(GETFIELD, "dog/lang/StackFrame", "registers", "[Ldog/lang/Value;");
		mv.visitLdcInsn(this.valueRegister);
		mv.visitInsn(AALOAD);
		mv.visitLdcInsn(this.outputRegister);
		mv.visitMethodInsn(INVOKEVIRTUAL, "dog/lang/Value", "put", "(Ljava/lang/Object;Ldog/lang/Value;I)V");

		setReturnRegister(mv, this.outputRegister);
		incrementProgramCounter(mv, instructionIndex);
	}
}
