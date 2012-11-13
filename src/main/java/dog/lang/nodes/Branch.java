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
import dog.lang.compiler.Function;
import dog.lang.instructions.Move;
import dog.lang.instructions.Jump;
import dog.lang.instructions.JumpIfTrue;

import java.util.ArrayList;

public class Branch extends Node {
	Node condition;
	Node trueBranch;
	Node falseBranch;

	public Branch(Node condition, Node trueBranch, Node falseBranch) {
		this(-1, condition, trueBranch, falseBranch);
	}

	public Branch(int line, Node condition, Node trueBranch, Node falseBranch) {
		super(line);
		this.condition = condition;
		this.trueBranch = trueBranch;
		this.falseBranch = falseBranch;

		setParentOfChild(condition);
		setParentOfChild(trueBranch);
		setParentOfChild(falseBranch);
	}

	public void compile(Symbol symbol) {
		int conditionRegister = -1;
		int trueRegister = -1;
		int falseRegister = -1;

		Symbol trueSymbol = symbol.nestedSymbol();
		Symbol falseSymbol = symbol.nestedSymbol();

		condition.compile(symbol);
		conditionRegister = symbol.currentOutputRegister;

		if(trueBranch != null) {
			trueBranch.compile(trueSymbol);
			trueRegister = trueSymbol.currentOutputRegister;
		}

		if(falseBranch != null) {
			falseBranch.compile(falseSymbol);
			falseRegister = falseSymbol.currentOutputRegister;
		}

		Move move;
		int outputRegister = symbol.registerGenerator.generate();

		move = new Move(this.line, outputRegister, trueSymbol.currentOutputRegister);
		trueSymbol.instructions.add(move);

		move = new Move(this.line, outputRegister, falseSymbol.currentOutputRegister);
		falseSymbol.instructions.add(move);

		Jump skipOverFalseBranch = new Jump(this.line, 1 + falseSymbol.instructions.size());
		trueSymbol.instructions.add(skipOverFalseBranch);

		JumpIfTrue skipToTrueBranch = new JumpIfTrue(this.line, conditionRegister, 2);
		symbol.instructions.add(skipToTrueBranch);

		Jump skipToFalseBranch = new Jump(this.line, 1 + trueSymbol.instructions.size());
		symbol.instructions.add(skipToFalseBranch);

		symbol.instructions.addAll(trueSymbol.instructions);
		symbol.instructions.addAll(falseSymbol.instructions);

		symbol.registerGenerator.release(conditionRegister);
		symbol.registerGenerator.release(trueRegister);
		symbol.registerGenerator.release(falseRegister);

		symbol.currentOutputRegister = outputRegister;
	}

	public ArrayList<Node> children() {
		ArrayList<Node> output = new ArrayList<Node>();

		if(condition != null) {
			output.add(condition);
		}

		if(trueBranch != null) {
			output.add(trueBranch);
		}

		if(falseBranch != null) {
			output.add(falseBranch);
		}

		return output;
	}
}




