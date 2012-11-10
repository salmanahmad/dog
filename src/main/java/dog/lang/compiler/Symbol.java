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

import java.util.ArrayList;
import java.util.HashMap;

public class Symbol {

	public String name;
	public String packageName;
	public String filePath;

	public int currentOutputRegister;

	public ArrayList<Instruction> instructions = new ArrayList<Instruction>();
	public ArrayList<Scope> scopes = new ArrayList<Scope>();

	public VariableGenerator variableGenerator = new VariableGenerator();
	public RegisterGenerator registerGenerator = new RegisterGenerator();

	public Symbol nestedSymbol() {
		Symbol nested = new Symbol();
		
		nested.name = this.name;
		nested.packageName = this.packageName;
		nested.filePath = this.filePath;

		nested.scopes = this.scopes;
		nested.variableGenerator = this.variableGenerator;
		nested.registerGenerator = this.registerGenerator;

		return nested;
	}
}




