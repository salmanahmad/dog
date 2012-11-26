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
import org.apache.commons.lang3.StringEscapeUtils;

public class LoadString extends Instruction implements Opcodes {
	public String string;

	public LoadString(int line, int outputRegister, String string) {
		super(line, outputRegister);
		this.string = string;
	}

	public String toString() {
		return String.format(":load_string %%r%d \"%s\"", outputRegister, StringEscapeUtils.escapeJava(string));
	}

	public void assemble(MethodVisitor mv, int instructionIndex, Label[] labels) {
		mv.visitLabel(labels[instructionIndex]);
		mv.visitVarInsn(ALOAD, 1);
		mv.visitFieldInsn(GETFIELD, "dog/lang/StackFrame", "registers", "[Ldog/lang/Value;");
		mv.visitIntInsn(SIPUSH, this.outputRegister);
		mv.visitTypeInsn(NEW, "dog/lang/StringValue");
		mv.visitInsn(DUP);
		mv.visitLdcInsn(this.string);
		mv.visitMethodInsn(INVOKESPECIAL, "dog/lang/StringValue", "<init>", "(Ljava/lang/String;)V");
		mv.visitInsn(AASTORE);

		incrementProgramCounter(mv);
	}


}

