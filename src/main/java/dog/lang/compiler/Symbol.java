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
import dog.lang.nodes.Node;

import java.util.ArrayList;
import java.util.HashMap;
import java.io.ByteArrayOutputStream;
import java.io.PrintWriter;

import org.objectweb.asm.*;
import org.objectweb.asm.util.*;

public abstract class Symbol {
	
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

	public void compileNodes() {
		this.node.compile(this);
		this.convertThrows();
	}

	public void convertThrows() {
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




