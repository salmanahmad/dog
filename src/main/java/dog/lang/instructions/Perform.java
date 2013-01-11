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

import java.util.HashMap;
import java.util.HashSet;
import org.objectweb.asm.*;

public class Perform extends Instruction {
	public int inputRegister1;
	public int inputRegister2;

	public String operation;

	static HashMap<String, String> operationMapping;
	static HashSet<String> unaryOperators;
	static {
		operationMapping = new HashMap<String, String>();

		operationMapping.put("==", "equalTo");
		operationMapping.put("!=", "notEqualTo");
		operationMapping.put("===", "identicalTo");
		operationMapping.put("!==", "notIdenticalTo");

		operationMapping.put("<=", "lessThanEqualTo");
		operationMapping.put(">=", "greaterThanEqualTo");
		operationMapping.put("<", "lessThan");
		operationMapping.put(">", "greaterThan");

		operationMapping.put("+", "plus");
		operationMapping.put("-", "minus");
		operationMapping.put("*", "multiply");
		operationMapping.put("/", "divide");
		operationMapping.put("%", "modulo");

		operationMapping.put("&&", "logicalAnd");
		operationMapping.put("||", "logicalOr");

		operationMapping.put("!", "logicalInverse");

		unaryOperators = new HashSet<String>();
		unaryOperators.add("!");
	}

	public Perform(int outputRegister, int inputRegister1, int inputRegister2, String operation) {
		this(-1, outputRegister, inputRegister1, inputRegister2, operation);
	}

	public Perform(int line, int outputRegister, int inputRegister1, int inputRegister2, String operation) {
		super(line, outputRegister);
		this.inputRegister1 = inputRegister1;
		this.inputRegister2 = inputRegister2;
		this.operation = operation;
	}

	public String toString() {
		return String.format(":perform %%r%d %%r%d %%r%d %s", outputRegister, inputRegister1, inputRegister2, operation);
	}

	public void assemble(MethodVisitor mv, int instructionIndex, Label[] labels) {
		mv.visitLabel(labels[instructionIndex]);
		
		String operationMethod = operationMapping.get(this.operation);
		if(operationMethod == null) {
			throw new RuntimeException("Invalid operation");
		}

		if(unaryOperators.contains(this.operation)) {
			mv.visitVarInsn(ALOAD, 1);
			mv.visitFieldInsn(GETFIELD, "dog/lang/StackFrame", "registers", "[Ldog/lang/Value;");
			mv.visitIntInsn(SIPUSH, this.outputRegister);
			mv.visitVarInsn(ALOAD, 1);
			mv.visitFieldInsn(GETFIELD, "dog/lang/StackFrame", "registers", "[Ldog/lang/Value;");
			mv.visitIntInsn(SIPUSH, this.inputRegister1);
			mv.visitInsn(AALOAD);
			mv.visitLdcInsn(this.inputRegister1);
			mv.visitMethodInsn(INVOKEVIRTUAL, "dog/lang/Value", operationMethod, "(I)Ldog/lang/Value;");
			mv.visitInsn(AASTORE);
		} else {
			mv.visitVarInsn(ALOAD, 1);
			mv.visitFieldInsn(GETFIELD, "dog/lang/StackFrame", "registers", "[Ldog/lang/Value;");
			mv.visitIntInsn(SIPUSH, this.outputRegister);
			mv.visitVarInsn(ALOAD, 1);
			mv.visitFieldInsn(GETFIELD, "dog/lang/StackFrame", "registers", "[Ldog/lang/Value;");
			mv.visitIntInsn(SIPUSH, this.inputRegister1);
			mv.visitInsn(AALOAD);
			mv.visitVarInsn(ALOAD, 1);
			mv.visitFieldInsn(GETFIELD, "dog/lang/StackFrame", "registers", "[Ldog/lang/Value;");
			mv.visitIntInsn(SIPUSH, this.inputRegister2);
			mv.visitInsn(AALOAD);
			mv.visitLdcInsn(this.inputRegister1);
			mv.visitLdcInsn(this.inputRegister2);
			mv.visitMethodInsn(INVOKEVIRTUAL, "dog/lang/Value", operationMethod, "(Ldog/lang/Value;II)Ldog/lang/Value;");
			mv.visitInsn(AASTORE);
		}
		

		setReturnRegister(mv, this.outputRegister);
		incrementProgramCounter(mv, instructionIndex);
	}
}

