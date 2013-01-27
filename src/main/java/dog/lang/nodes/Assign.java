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
import dog.lang.instructions.ReadVariable;
import dog.lang.instructions.WriteVariable;
import dog.lang.instructions.LoadString;
import dog.lang.instructions.LoadNumber;

import java.util.ArrayList;

public class Assign extends Node {
	ArrayList<Object> path;
	Node value;

	public Assign(ArrayList<Object> path, Node value) {
		this(-1, path, value);
	}

	public Assign(int line, ArrayList<Object> path, Node value) {
		super(line);
		this.path = path;
		this.value = value;
	}

	public void compile(Symbol symbol) {
		value.compile(symbol);
		int valueRegister = symbol.currentOutputRegister;

		String variableName = (String)path.remove(0);
		int variable = symbol.variableGenerator.getIndexForVariable(variableName);

		if(path.size() == 0) {
			WriteVariable write = new WriteVariable(this.line, variable, valueRegister);
			symbol.instructions.add(write);
			symbol.currentOutputRegister = valueRegister;
			return;
		}

		int register = symbol.registerGenerator.generate();

		ReadVariable read = new ReadVariable(this.line, register, variable);
		symbol.instructions.add(read);

		ArrayList<Integer> componentRegisters = new ArrayList<Integer>();
		ArrayList<Integer> intermediateRegisters = new ArrayList<Integer>();

		intermediateRegisters.add(register);

		for(int i = 0; i < path.size(); i++) {
			Object component = path.get(i);

			int previousRegister = intermediateRegisters.get(i);
			int intermediateRegister = symbol.registerGenerator.generate();
			int componentRegister;


			if(component instanceof Number) {
				componentRegister = symbol.registerGenerator.generate();
				LoadNumber load = new LoadNumber(this.line, componentRegister, ((Number)component).doubleValue());
				symbol.instructions.add(load);
			} else if(component instanceof String) {
				componentRegister = symbol.registerGenerator.generate();
				LoadString load = new LoadString(this.line, componentRegister, (String)component);
				symbol.instructions.add(load);
			} else if(component instanceof Node) {
				((Node)component).compile(symbol);
				componentRegister = symbol.currentOutputRegister;
			} else {
				throw compileError("Invalid assign path during compilation");
			}

			if(i != (path.size() - 1)) {
				dog.lang.instructions.Access access = new dog.lang.instructions.Access(this.line, intermediateRegister, previousRegister, componentRegister);
				symbol.instructions.add(access);

				intermediateRegisters.add(intermediateRegister);
				componentRegisters.add(componentRegister);
			} else {
				dog.lang.instructions.Assign assign = new dog.lang.instructions.Assign(this.line, previousRegister, componentRegister, valueRegister);
				symbol.instructions.add(assign);

				symbol.registerGenerator.release(intermediateRegister);
				symbol.registerGenerator.release(componentRegister);
			}
		}

		for(int i = intermediateRegisters.size() - 2; i >= 0 ; i--) {
			int previousRegister = intermediateRegisters.get(i + 1);
			int intermediateRegister = intermediateRegisters.get(i);
			int componentRegister = componentRegisters.get(i);

			dog.lang.instructions.Assign assign = new dog.lang.instructions.Assign(this.line, intermediateRegister, componentRegister, previousRegister);
			symbol.instructions.add(assign);
		}

		WriteVariable write = new WriteVariable(variable, register);
		symbol.instructions.add(write);

		symbol.registerGenerator.release(valueRegister);

		for(int r : intermediateRegisters) {
			if(r != register) {
				symbol.registerGenerator.release(r);
			}
		}

		for(int r : componentRegisters) {
			symbol.registerGenerator.release(r);
		}

		symbol.currentOutputRegister = register;
	}

	public ArrayList<Node> children() {
		ArrayList<Node> list = new ArrayList<Node>();

		for(Object component : path) {
			if(component instanceof Node) {
				list.add((Node)component);
			}
		}

		list.add(value);

		return list;
	}
}




