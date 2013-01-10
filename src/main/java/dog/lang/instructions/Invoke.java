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

import dog.lang.compiler.Identifier;
import dog.lang.Resolver;

import java.util.ArrayList;
import org.objectweb.asm.*;

public class Invoke extends Instruction {

	boolean asynchronous;
	String functionIdentifier;
	ArrayList<Integer> arguments;

	public Invoke(int outputRegister, boolean asynchronous, String functionIdentifier, ArrayList<Integer> arguments) {
		this(-1, outputRegister, asynchronous, functionIdentifier, arguments);
	}

	public Invoke(int line, int outputRegister, boolean asynchronous, String functionIdentifier, ArrayList<Integer> arguments) {
		super(line, outputRegister);
		this.asynchronous = asynchronous;
		this.functionIdentifier = functionIdentifier;
		this.arguments = arguments;
	}

	public String toString() {
		String args = "";
		for(int arg : arguments) {
			args += "%r" + arg + " ";
		}

		return String.format(":invoke %%r%d %b '%s' %s", outputRegister, asynchronous, functionIdentifier, args);
	}

	public void assemble(MethodVisitor mv, int instructionIndex, Label[] labels) {
		mv.visitLabel(labels[instructionIndex]);

		// TODO - Do I have to worry about waiting here if a value is pending or will I
		// have already been waited before this point?
		
		// TODO - Strongly consider making this its own function instead of bytecode. The JIT
		// will most likely inline it anyways and it makes it more robust and easier to deal with...

		setReturnRegister(mv, this.outputRegister);
		incrementProgramCounter(mv, instructionIndex);

		mv.visitTypeInsn(NEW, "dog/lang/Signal");
		mv.visitInsn(DUP);

		if(this.asynchronous) {
			mv.visitFieldInsn(GETSTATIC, "dog/lang/Signal$Type", "SCHEDULE", "Ldog/lang/Signal$Type;");
		} else {
			mv.visitFieldInsn(GETSTATIC, "dog/lang/Signal$Type", "INVOKE", "Ldog/lang/Signal$Type;");
		}
		
		mv.visitTypeInsn(NEW, "dog/lang/StackFrame");
		mv.visitInsn(DUP);
		mv.visitTypeInsn(NEW, Resolver.encodeSymbol(this.functionIdentifier));
		mv.visitInsn(DUP);
		mv.visitMethodInsn(INVOKESPECIAL, Resolver.encodeSymbol(this.functionIdentifier), "<init>", "()V");
		
		mv.visitLdcInsn(arguments.size());
		mv.visitTypeInsn(ANEWARRAY, "dog/lang/Value");
		
		for (int i = 0; i < arguments.size(); i++) {
			mv.visitInsn(DUP);
			mv.visitLdcInsn(i);
			mv.visitVarInsn(ALOAD, 1);
			mv.visitFieldInsn(GETFIELD, "dog/lang/StackFrame", "registers", "[Ldog/lang/Value;");
			mv.visitLdcInsn(arguments.get(i));
			mv.visitInsn(AALOAD);
			mv.visitInsn(AASTORE);
		}

		mv.visitMethodInsn(INVOKESPECIAL, "dog/lang/StackFrame", "<init>", "(Ldog/lang/Continuable;[Ldog/lang/Value;)V");
		mv.visitMethodInsn(INVOKESPECIAL, "dog/lang/Signal", "<init>", "(Ldog/lang/Signal$Type;Ldog/lang/StackFrame;)V");
		mv.visitInsn(ARETURN);
	}
}
