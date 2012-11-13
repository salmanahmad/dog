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

package dog.lang.nodes;

import dog.lang.Value;
import dog.lang.compiler.Compiler;
import dog.lang.compiler.Constant;
import dog.lang.compiler.Symbol;
import dog.lang.instructions.LoadValue;

import java.util.ArrayList;

// TODO: Should constants be Node instead of a Value. The first time it is called I memorize it
// and from then on I just return the results? Right now that means that I will not be able to 
// do things like define a constant of a runtime type (since I will not have that information)
// available to me during the parser stage, right? Perhaps I add a new field to this class called
// "type" to save a string of the symbol to use? Maybe?

// If I do decide to change this and make it a memorized result on the first try then I should
// Remove the readConstant instruction and compile into a function definition that is replaced
// with an invoke in the "Access" node instead of the ReadConstant

public class ConstantDefinition extends Definition {
	Value value;

	public ConstantDefinition(String name, Value value) {
		this(-1, name, value);
	}

	public ConstantDefinition(int line, String name, Value value) {
		super(line, name);
		this.value = value;
	}

	public void compile(Symbol symbol) {
		if(symbol.name.equals(this.fullyQualifiedName())) {
			int outputRegister = symbol.registerGenerator.generate();
			LoadValue load = new LoadValue(this.line, outputRegister, value);
			symbol.instructions.add(load);

			dog.lang.instructions.Return ret = new dog.lang.instructions.Return(this.line, outputRegister);
			symbol.instructions.add(ret);

			symbol.currentOutputRegister = outputRegister;
		} else {
			// TODO: I should consider returning the actual constant that will
			// be assignable to the caller code.
			symbol.currentOutputRegister = -1;
		}
	}

	public void scaffold(Compiler compiler) {
		Constant symbol = new Constant(this.fullyQualifiedName(), this);
		compiler.addSymbol(symbol);
		super.scaffold(compiler);
	}

	public ArrayList<Node> children() {
		return new ArrayList<Node>();
	}
}
