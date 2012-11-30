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

public class Instruction implements Opcodes {
	public int line;
	public int outputRegister;

	// TODO: if any operand register (especially function invocations) is "-1" that means that I have to replace the value with NullValue

	public Instruction() {
		this.line = -1;
		this.outputRegister = -1;
	}

	public Instruction(int line) {
		this.line = line;
	}

	public Instruction(int line, int outputRegister) {
		this.line = line;
		this.outputRegister = outputRegister;
	}

	public void assemble(MethodVisitor mv, int instructionIndex, Label[] labels) {
		throw new RuntimeException("Assemble not implemented for : " + this.getClass().getName());
	}

	public void setReturnRegister(MethodVisitor mv, int register) {
		mv.visitVarInsn(ALOAD, 1);
		mv.visitIntInsn(BIPUSH, register);
		mv.visitFieldInsn(PUTFIELD, "dog/lang/StackFrame", "returnRegister", "I");
	}

	public void incrementProgramCounter(MethodVisitor mv) {
		mv.visitVarInsn(ALOAD, 1);
		mv.visitInsn(DUP);
		mv.visitFieldInsn(GETFIELD, "dog/lang/StackFrame", "programCounter", "I");
		mv.visitInsn(ICONST_1);
		mv.visitInsn(IADD);
		mv.visitFieldInsn(PUTFIELD, "dog/lang/StackFrame", "programCounter", "I");
	}
}
