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

public class JumpIfTrue extends Instruction {
	int offset;
	int inputRegister;

	public JumpIfTrue(int inputRegister, int offset) {
		this(-1, offset, inputRegister);
	}

	public JumpIfTrue(int line, int inputRegister, int offset) {
		super(line);
		this.offset = offset;
		this.inputRegister = inputRegister;
	}

	public String toString() {
		return String.format(":jump_if_true %%r%d %d", inputRegister, offset);
	}

	public void assemble(MethodVisitor mv, int instructionIndex, Label[] labels) {
		mv.visitLabel(labels[instructionIndex]);

		int destinationIndex = instructionIndex + this.offset;

		mv.visitVarInsn(ALOAD, 1);
		mv.visitFieldInsn(GETFIELD, "dog/lang/StackFrame", "registers", "[Ldog/lang/Value;");
		mv.visitIntInsn(SIPUSH, inputRegister);
		mv.visitInsn(AALOAD);
		mv.visitMethodInsn(INVOKEVIRTUAL, "dog/lang/Value", "booleanEquivalent", "()Z");

		Label l0 = new Label();
		mv.visitJumpInsn(IFEQ, l0);

		// If booleanEquivalent is not zero (true)
		mv.visitVarInsn(ALOAD, 1);
		mv.visitIntInsn(SIPUSH, destinationIndex);
		mv.visitFieldInsn(PUTFIELD, "dog/lang/StackFrame", "programCounter", "I");
		mv.visitJumpInsn(GOTO, labels[destinationIndex]);

		// If booleanEquivalent is zero (false)
		mv.visitLabel(l0);
		incrementProgramCounter(mv);
	}
}

