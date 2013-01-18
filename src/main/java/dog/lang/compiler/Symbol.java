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

import dog.lang.instructions.Instruction;
import dog.lang.instructions.Throw;
import dog.lang.instructions.ScopeStart;
import dog.lang.instructions.ScopeEnd;
import dog.lang.nodes.Node;
import dog.lang.Resolver;

import java.util.Stack;
import java.util.ArrayList;
import java.util.HashMap;
import java.io.ByteArrayOutputStream;
import java.io.PrintWriter;


import org.objectweb.asm.*;
import org.objectweb.asm.util.*;

public abstract class Symbol implements Opcodes {
	
	Compiler compiler;

	public String name;
	public String filePath;

	public Node node;
	public byte[] bytecode;

	public int currentOutputRegister;

	// TODO: Rename this as a catchTable with CatchEntry?
	public ArrayList<Scope> scopes = new ArrayList<Scope>();
	public ArrayList<Instruction> instructions = new ArrayList<Instruction>();

	public VariableGenerator variableGenerator = new VariableGenerator();
	public RegisterGenerator registerGenerator = new RegisterGenerator();

	public abstract String toDogBytecodeString();
	public abstract void compile();

	public Symbol(String name, Node node, Compiler compiler) {
		this.name = name;
		this.node = node;
		this.filePath = node.filePath;
		this.compiler = compiler;
	}


	public String toJVMBytecodeString() {
		ByteArrayOutputStream outputStream = new ByteArrayOutputStream();

		ClassReader classReader = new ClassReader(this.bytecode);
		PrintWriter printWriter = new PrintWriter(outputStream);
		TraceClassVisitor traceClassVisitor = new TraceClassVisitor(printWriter);
		classReader.accept(traceClassVisitor, ClassReader.SKIP_DEBUG);

		return outputStream.toString();
	}

	public Compiler getCompiler() {
		return compiler;
	}

	public Symbol nestedSymbol() {
		Symbol nested = null;

		if(this instanceof Function) {
			nested = new Function(this.name, this.node, this.compiler);
		} else if(this instanceof Type) {
			nested = new Type(this.name, this.node, this.compiler);
		} else if(this instanceof Constant) {
			nested = new Constant(this.name, this.node, this.compiler);
		}

		nested.scopes = this.scopes;
		nested.variableGenerator = this.variableGenerator;
		nested.registerGenerator = this.registerGenerator;

		return nested;
	}

	public void compileContinuable(String className) {
		compileNodes();

		ClassWriter cw = new ClassWriter(ClassWriter.COMPUTE_MAXS);
		FieldVisitor fv;
		MethodVisitor mv;
		AnnotationVisitor av0;

		cw.visit(V1_5, ACC_PUBLIC + ACC_SUPER, Resolver.encodeSymbol(name), null, className, null);
		cw.visitSource("app.dog", null);

		// Add the default constructor
		mv = cw.visitMethod(ACC_PUBLIC, "<init>", "()V", null, null);
		mv.visitCode();
		mv.visitVarInsn(ALOAD, 0);
		mv.visitMethodInsn(INVOKESPECIAL, className, "<init>", "()V");
		mv.visitInsn(RETURN);
		mv.visitMaxs(1, 1);
		mv.visitEnd();

		// Add the meta information
		mv = cw.visitMethod(ACC_PUBLIC, "getVariableTable", "()Ljava/util/HashMap;", "()Ljava/util/HashMap<Ljava/lang/String;Ljava/lang/Integer;>;", null);
		mv.visitCode();
		mv.visitTypeInsn(NEW, "java/util/HashMap");
		mv.visitInsn(DUP);
		mv.visitMethodInsn(INVOKESPECIAL, "java/util/HashMap", "<init>", "()V");
		mv.visitVarInsn(ASTORE, 1);
		for(String variableName : this.variableGenerator.variables.keySet()) {
			mv.visitVarInsn(ALOAD, 1);
			mv.visitLdcInsn(variableName);
			mv.visitIntInsn(SIPUSH, variableGenerator.variables.get(variableName));
			mv.visitMethodInsn(INVOKESTATIC, "java/lang/Integer", "valueOf", "(I)Ljava/lang/Integer;");
			mv.visitMethodInsn(INVOKEVIRTUAL, "java/util/HashMap", "put", "(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;");
			mv.visitInsn(POP);
		}
		mv.visitVarInsn(ALOAD, 1);
		mv.visitInsn(ARETURN);
		mv.visitMaxs(0, 0);
		mv.visitEnd();

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
		Label defaultLabel = new Label();
		Label[] labels = new Label[instructions.size() + 1];

		for (int index = 0; index < instructions.size(); index++) {
			labels[index] = new Label();
		}

		labels[labels.length - 1] = returnLabel;

		// Start the switch statement
		mv.visitVarInsn(ALOAD, 1);
		mv.visitFieldInsn(GETFIELD, "dog/lang/StackFrame", "programCounter", "I");
		mv.visitTableSwitchInsn(0, labels.length - 1, defaultLabel, labels);

		for (int index = 0; index < instructions.size(); index++) {
			Instruction instruction = instructions.get(index);

			Label lineLabel = new Label();
			mv.visitLabel(lineLabel);
			mv.visitLineNumber(instruction.line, lineLabel);

			instruction.assemble(mv, index, labels);
		}

		// Insert a dummy label so I can avoid the fence post problem
		mv.visitLabel(returnLabel);
		mv.visitLabel(defaultLabel);
		
		mv.visitTypeInsn(NEW, "dog/lang/Signal");
		mv.visitInsn(DUP);
		mv.visitFieldInsn(GETSTATIC, "dog/lang/Signal$Type", "RETURN", "Ldog/lang/Signal$Type;");
		mv.visitMethodInsn(INVOKESPECIAL, "dog/lang/Signal", "<init>", "(Ldog/lang/Signal$Type;)V");
		mv.visitInsn(ARETURN);

		mv.visitMaxs(0, 0);
		mv.visitEnd();
		cw.visitEnd();

		this.bytecode = cw.toByteArray();
	}

	public void compileNodes() {
		this.node.compile(this);
		this.convertThrows();
	}

	public void convertThrows() {
		this.scopes = new ArrayList<Scope>();

		Stack<Object[]> starts = new Stack<Object[]>();

		for(int i = 0; i < instructions.size(); i++) {
			Instruction instruction = instructions.get(i);
			if(instruction instanceof ScopeStart) {
				starts.push(new Object[] { instruction, i });
			}

			if(instruction instanceof ScopeEnd) {
				Object[] start = starts.pop();
				ScopeStart scopeStart = (ScopeStart)start[0];

				Scope scope = new Scope();
				scope.start = (Integer)start[1];
				scope.end = i;
				
				scope.label = scopeStart.label;
				scope.returnRegister = scopeStart.returnRegister;
				scope.offsetFromEnd = scopeStart.offsetFromEnd;

				scopes.add(scope);
			}
		}

		for(int i = 0; i < instructions.size(); i++) {
			Instruction instruction = instructions.get(i);

			if(instruction instanceof Throw) {
				Throw t = (Throw)instruction;
				Scope bestScope = null;

				for(Scope scope : scopes) {
					if(scope.label.equals(t.label) && scope.start <= i && scope.end >= i) {
						if (bestScope == null || (scope.end - scope.start) < (bestScope.end - bestScope.start)) {
							bestScope = scope;
						}
					}
				}

				if(bestScope == null) {
					throw new RuntimeException("Could not resolve throw statement.");
				}

				t.outputRegister = bestScope.returnRegister;
				t.destination = bestScope.end + bestScope.offsetFromEnd;
			}
		}
	}
}




