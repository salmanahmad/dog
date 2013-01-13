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

package dog.packages.dog;

import dog.lang.Value;
import dog.lang.StructureValue;
import dog.lang.NumberValue;
import dog.lang.StringValue;
import dog.lang.Function;
import dog.lang.Signal;
import dog.lang.StackFrame;
import dog.lang.annotation.Symbol;

import java.util.List;
import java.util.ArrayList;
import java.util.TreeSet;
import java.util.SortedSet;
import java.util.Collections;

@Symbol("dog.structure_keys:")
public class StructureKeys extends Function {

	public int getRegisterCount() {
		return 1;
	}

	public int getVariableCount() {
		return 1;
	}
	// TODO: Sort the keys...
	public Signal resume(StackFrame frame) {
		Value value = frame.variables[0];
		if(value instanceof StructureValue) {
			StructureValue struct = (StructureValue)value;
			StructureValue returnList = (StructureValue)frame.getRuntime().getResolver().resolveSymbol("dog.array");

			double index = 0;
			SortedSet<Object> keys = new TreeSet<Object>(struct.value.keySet());

			for(Object key : keys) {
				if(key instanceof String) {
					returnList.value.put(index, new StringValue((String)key));
				} else if(key instanceof Number) {
					returnList.value.put(index, new NumberValue((Double)key));
				}
				
				index++;
			}
			
			frame.registers[0] = returnList;
		} else {
			frame.registers[0] = (StructureValue)frame.getRuntime().getResolver().resolveSymbol("dog.array");
		}

		frame.returnRegister = 0;
		return new Signal(Signal.Type.RETURN);
	}
}

