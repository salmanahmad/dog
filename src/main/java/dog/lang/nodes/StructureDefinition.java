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
import dog.lang.instructions.LoadStructure;
import dog.lang.instructions.LoadString;
import dog.lang.instructions.LoadNumber;
import dog.lang.instructions.Build;

import java.util.ArrayList;
import java.util.HashMap;

public class StructureDefinition extends Definition {
	HashMap<Object, Node> properties;

	public StructureDefinition(String name, HashMap<Object, Node> properties) {
		this(-1, name, properties);
	}

	public StructureDefinition(int line, String name, HashMap<Object, Node> properties) {
		super(-1, name);
		this.properties = properties;
	}

	public void compile(Symbol symbol) {
		if(symbol.name.equals(this.fullyQualifiedName())) {			
			// TODO: Move the "this" variable into the structureRegister.
			int structureRegister = 0;

			for(Object key : properties.keySet()) {
				Node property = properties.get(key);

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

			// TODO: I need to return the "this" variable

		} else {
			// TODO: I should consider returning the TyepPointer so that it is 
			// available to the caller code.
			symbol.currentOutputRegister = -1;
		}
	}

	public ArrayList<Node> children() {
		return new ArrayList<Node>();
	}
}
