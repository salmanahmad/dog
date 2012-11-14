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
import dog.lang.instructions.Throw;

import java.util.ArrayList;

public class Break extends Node {
	Node expression;

	public Break(Node expression) {
		this(-1, expression);
	}

	public Break(int line, Node expression) {
		super(line);
		this.expression = expression;

		setParentOfChild(expression);
	}

	public void compile(Symbol symbol) {
		int inputRegister = -1;

		if(expression != null) {
			expression.compile(symbol);
			inputRegister = symbol.currentOutputRegister;
		}

		Throw instruction = new Throw(this.line, inputRegister, "break");
		symbol.instructions.add(instruction);
		symbol.currentOutputRegister = -1;

		symbol.registerGenerator.release(inputRegister);
	}

	public ArrayList<Node> children() {
		ArrayList<Node> list = new ArrayList<Node>();

		if(expression != null) {
			list.add(expression);
		}

		return list;
	}
}



