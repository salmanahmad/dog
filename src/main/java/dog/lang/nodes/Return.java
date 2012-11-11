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

import dog.lang.compiler.Symbol;

import java.util.ArrayList;
import java.util.Arrays;

public class Return extends Node {
	Node expression;

	public Return(Node expression) {
		this(-1, expression);
	}

	public Return(int line, Node expression) {
		super(line);
		this.expression = expression;

		setParentOfChild(expression);
	}

	public void compile(Symbol symbol) {
		int register = -1;

		if(expression != null) {
			expression.compile(symbol);
			register = symbol.currentOutputRegister;
		}

		dog.lang.instructions.Return instruction = new dog.lang.instructions.Return(this.line, register);
		symbol.instructions.add(instruction);

		symbol.registerGenerator.release(register);

		symbol.currentOutputRegister = -1;
	}

	public ArrayList<Node> children() {
		if (expression == null) {
            return new ArrayList<Node>();
		} else {
            return new ArrayList<Node>(Arrays.asList(expression));
		}
	}
}


