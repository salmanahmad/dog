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
import dog.lang.NullValue;
import dog.lang.StringValue;
import dog.lang.Type;
import dog.lang.Signal;
import dog.lang.StackFrame;
import dog.lang.annotation.Symbol;

@Symbol("dog.query")
public class Query extends Type {
	public Signal resume(StackFrame frame) {
		frame.registers[0] = frame.variables[0];
		frame.registers[0].put("container", new NullValue());
		frame.registers[0].put("predicate", new NullValue());
		frame.returnRegister = 0;

		return new Signal(Signal.Type.RETURN);
	}
}

