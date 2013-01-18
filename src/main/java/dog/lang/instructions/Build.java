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

import dog.lang.Resolver;
import org.objectweb.asm.*;

public class Build extends Instruction {
	String typeIdentifier;

	public Build(int outputRegister, String typeIdentifier) {
		this(-1, outputRegister, typeIdentifier);
	}

	public Build(int line, int outputRegister, String typeIdentifier) {
		super(line, outputRegister);
		this.typeIdentifier = typeIdentifier;
	}

	public String toString() {
		return String.format(":build %%r%d '%s'", outputRegister, typeIdentifier);
	}

	public void assemble(MethodVisitor mv, int instructionIndex, Label[] labels) {
		mv.visitLabel(labels[instructionIndex]);
		
		setReturnRegister(mv, this.outputRegister);
		incrementProgramCounter(mv, instructionIndex);

		mv.visitTypeInsn(NEW, "dog/lang/Signal");
		mv.visitInsn(DUP);
		mv.visitFieldInsn(GETSTATIC, "dog/lang/Signal$Type", "INVOKE", "Ldog/lang/Signal$Type;");
		mv.visitTypeInsn(NEW, "dog/lang/StackFrame");
		mv.visitInsn(DUP);
		mv.visitTypeInsn(NEW, Resolver.encodeSymbol(this.typeIdentifier));
		mv.visitInsn(DUP);
		mv.visitMethodInsn(INVOKESPECIAL, Resolver.encodeSymbol(this.typeIdentifier), "<init>", "()V");
		mv.visitInsn(ICONST_1);
		mv.visitTypeInsn(ANEWARRAY, "dog/lang/Value");
		mv.visitInsn(DUP);
		mv.visitInsn(ICONST_0);
		mv.visitTypeInsn(NEW, Resolver.encodeSymbol(this.typeIdentifier));
		mv.visitInsn(DUP);
		mv.visitMethodInsn(INVOKESPECIAL, Resolver.encodeSymbol(this.typeIdentifier), "<init>", "()V");
		mv.visitInsn(AASTORE);
		mv.visitMethodInsn(INVOKESPECIAL, "dog/lang/StackFrame", "<init>", "(Ldog/lang/Continuable;[Ldog/lang/Value;)V");
		mv.visitMethodInsn(INVOKESPECIAL, "dog/lang/Signal", "<init>", "(Ldog/lang/Signal$Type;Ldog/lang/StackFrame;)V");
		mv.visitInsn(ARETURN);
	}

}
