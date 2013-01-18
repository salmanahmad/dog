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

public class ReadVariable extends Instruction {
	int inputRegister;

	public ReadVariable(int outputRegister, int inputRegister) {
		this(-1, outputRegister, inputRegister);
	}

	public ReadVariable(int line, int outputRegister, int inputRegister) {
		super(line, outputRegister);
		this.inputRegister = inputRegister;
	}

	public String toString() {
		return String.format(":read_variable %%r%d %%v%d", outputRegister, inputRegister);
	}

	public void assemble(MethodVisitor mv, int instructionIndex, Label[] labels) {
		mv.visitLabel(labels[instructionIndex]);
		
		mv.visitVarInsn(ALOAD, 1);
		mv.visitFieldInsn(GETFIELD, "dog/lang/StackFrame", "registers", "[Ldog/lang/Value;");
		mv.visitIntInsn(SIPUSH, this.outputRegister);
		mv.visitVarInsn(ALOAD, 1);
		mv.visitFieldInsn(GETFIELD, "dog/lang/StackFrame", "variables", "[Ldog/lang/Value;");
		mv.visitIntInsn(SIPUSH, this.inputRegister);
		mv.visitInsn(AALOAD);
		mv.visitInsn(AASTORE);

		setReturnRegister(mv, this.outputRegister);
		incrementProgramCounter(mv, instructionIndex);
	}

}
