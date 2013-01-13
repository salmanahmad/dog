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

@Symbol("dog.structure_size:")
public class StructureSize extends Function {

	public int getRegisterCount() {
		return 1;
	}

	public int getVariableCount() {
		return 1;
	}

	public Signal resume(StackFrame frame) {
		Value value = frame.variables[0];
		if(value instanceof StructureValue) {
			StructureValue struct = (StructureValue)value;
			frame.registers[0] = new NumberValue(struct.value.size());
		} else {
			frame.registers[0] = new NumberValue(0);
		}

		frame.returnRegister = 0;
		return new Signal(Signal.Type.RETURN);
	}
}

