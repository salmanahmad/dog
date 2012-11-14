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
import dog.lang.compiler.Identifier;
import dog.lang.instructions.LoadStructure;
import dog.lang.instructions.LoadString;
import dog.lang.instructions.LoadNumber;
import dog.lang.instructions.Build;

import java.util.ArrayList;
import java.util.HashMap;

import org.apache.commons.lang3.StringUtils;

public class StructureLiteral extends Node {
	Identifier type;
	HashMap<Object, Node> value;

	public StructureLiteral(HashMap<Object, Node> value) {
		this(null, value);
	}

	public StructureLiteral(Identifier type, HashMap<Object, Node> value) {
		this(-1, type, value);
	}

	public StructureLiteral(int line, Identifier type, HashMap<Object, Node> value) {
		super(line);
		this.type = type;
		this.value = value;	
	}

	public void compile(Symbol symbol) {
		int structureRegister = symbol.registerGenerator.generate();

		if(type == null) {
			LoadStructure structure = new LoadStructure(this.line, structureRegister);
			symbol.instructions.add(structure);
		} else {
			String typeIdentifier;

			if(type.scope == Identifier.Scope.EXTERNAL) {
				typeIdentifier = StringUtils.join(type.path, ".");
			} else {
				typeIdentifier = this.packageName + "." + StringUtils.join(type.path, ".");
			}

			if(symbol.getCompiler().searchForSymbols(typeIdentifier).size() != 1) {
				throw new RuntimeException("Unable to unique identify the type symbol.");
			}

			Build structure = new Build(this.line, structureRegister, typeIdentifier);
			symbol.instructions.add(structure);
		}

		for(Object key : value.keySet()) {
			Node property = value.get(key);

			int keyRegister = symbol.registerGenerator.generate();

			if(key instanceof Number) {
				Number number = (Number)key;

				LoadNumber loadKey = new LoadNumber(property.line, keyRegister, number.doubleValue());
				symbol.instructions.add(loadKey);
			} else if (key instanceof String) {
				String string = (String)key;
				
				LoadString loadKey = new LoadString(property.line, keyRegister, string);
				symbol.instructions.add(loadKey);
			} else {
				throw new RuntimeException("Invalid structure key.");
			}

			property.compile(symbol);
			int propertyRegister = symbol.currentOutputRegister;

			dog.lang.instructions.Assign assignStructure = new dog.lang.instructions.Assign(property.line, structureRegister, keyRegister, propertyRegister);
			symbol.instructions.add(assignStructure);

			symbol.registerGenerator.release(keyRegister);
			symbol.registerGenerator.release(propertyRegister);
		}

		symbol.currentOutputRegister = structureRegister;
	}

	public ArrayList<Node> children() {
		return new ArrayList<Node>(value.values());
	}
}



