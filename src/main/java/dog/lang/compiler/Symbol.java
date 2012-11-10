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

import dog.lang.compiler.instructions.Instruction;

import java.util.ArrayList;

public class Symbol {

	public String name;
	public String packageName;
	public String filePath;

	public ArrayList<Instruction> instructions = new ArrayList<Instruction>();
	public ArrayList<Scope> scopes = new ArrayList<Scope>();

	public RegisterGenerator registerAllocator = new RegisterGenerator();
}




