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

import dog.lang.nodes.Node;

import java.util.ArrayList;
import java.util.HashMap;

public class Symbol {
	
	public String name;
	public String filePath;

	Node node;
	Compiler compiler;

	public int currentOutputRegister;

	// TODO: Rename this as a catchTable with CatchEntry?
	public ArrayList<Scope> scopes = new ArrayList<Scope>();
	public ArrayList<Instruction> instructions = new ArrayList<Instruction>();

	public VariableGenerator variableGenerator = new VariableGenerator();
	public RegisterGenerator registerGenerator = new RegisterGenerator();

	public Symbol(String name, Node node, Compiler compiler) {
		this.name = name;
		this.node = node;
		this.filePath = node.filePath;
		this.compiler = compiler;
	}

	public Compiler getCompiler() {
		return compiler;
	}

	public Symbol nestedSymbol() {
		Symbol nested = new Symbol(this.name, this.node, this.compiler);

		nested.scopes = this.scopes;
		nested.variableGenerator = this.variableGenerator;
		nested.registerGenerator = this.registerGenerator;

		return nested;
	}
}




