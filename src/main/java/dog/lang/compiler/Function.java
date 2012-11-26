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

package dog.lang.compiler;

import dog.lang.nodes.Node;
import dog.lang.instructions.Instruction;
import dog.lang.Resolver;

import org.objectweb.asm.*;

public class Function extends Symbol implements Opcodes {
	public Function(String name, Node node, Compiler compiler) {
		super(name, node, compiler);
	}

	public String toDogBytecodeString() {
		String output = "";
		output += String.format("; function: %s\n", name);
		output += String.format("; variables: %d stack: %d\n", this.variableGenerator.variableCount(), registerGenerator.registerCount());

		for(int i = 0; i < instructions.size(); i++) {
			output += String.format("%04d %s\n", i, instructions.get(i).toString());
		}

		output += "\n\n\n";

		return output;
	}

	public String toJVMBytecodeString() {
		return null;
	}

	public void compile() {
		compileNodes();

		ClassWriter cw = new ClassWriter(ClassWriter.COMPUTE_FRAMES);
		FieldVisitor fv;
		MethodVisitor mv;
		AnnotationVisitor av0;

		cw.visit(V1_5, ACC_PUBLIC + ACC_SUPER, Resolver.encodeSymbol(name), null, "dog/lang/Function", null);

		// Add the default constructor
		mv = cw.visitMethod(ACC_PUBLIC, "<init>", "()V", null, null);
		mv.visitCode();
		mv.visitVarInsn(ALOAD, 0);
		mv.visitMethodInsn(INVOKESPECIAL, "dog/lang/Function", "<init>", "()V");
		mv.visitInsn(RETURN);
		mv.visitMaxs(1, 1);
		mv.visitEnd();

		// Add the register count information
		mv = cw.visitMethod(ACC_PUBLIC, "getRegisterCount", "()I", null, null);
		mv.visitCode();
		mv.visitIntInsn(SIPUSH, registerGenerator.registerCount());
		mv.visitInsn(IRETURN);
		mv.visitMaxs(1, 1);
		mv.visitEnd();

		// Add the variable count information
		mv = cw.visitMethod(ACC_PUBLIC, "getVariableCount", "()I", null, null);
		mv.visitCode();
		mv.visitIntInsn(SIPUSH, this.variableGenerator.variableCount());
		mv.visitInsn(IRETURN);
		mv.visitMaxs(1, 1);
		mv.visitEnd();

		// Start the body of the resume method
		mv = cw.visitMethod(ACC_PUBLIC, "resume", "(Ldog/lang/StackFrame;)Ldog/lang/Signal;", null, null);
		mv.visitCode();

		// Create switch statement for continuations
		Label returnLabel = new Label();
		Label[] labels = new Label[instructions.size() + 1];

		for (int index = 0; index < instructions.size(); index++) {
			labels[index] = new Label();
		}

		labels[labels.length - 1] = returnLabel;

		mv.visitTableSwitchInsn(0, labels.length, returnLabel, labels);

		for (int index = 0; index < instructions.size(); index++) {
			Instruction instruction = instructions.get(index);
			instruction.assemble(mv, index, labels);
		}

		mv.visitLabel(returnLabel);
		mv.visitTypeInsn(NEW, "dog/lang/Signal");
		mv.visitInsn(DUP);
		mv.visitFieldInsn(GETSTATIC, "dog/lang/Signal$Type", "RETURN", "Ldog/lang/Signal$Type;");
		mv.visitVarInsn(ALOAD, 1);
		mv.visitMethodInsn(INVOKESPECIAL, "dog/lang/Signal", "<init>", "(Ldog/lang/Signal$Type;Ldog/lang/StackFrame;)V");
		mv.visitInsn(ARETURN);

		mv.visitMaxs(0, 0);
		mv.visitEnd();
		cw.visitEnd();

		this.bytecode = cw.toByteArray();
	}
}
