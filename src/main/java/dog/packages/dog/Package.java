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

@Symbol("dog.package")
public class Package extends Type {

	public Signal resume(StackFrame frame) {
		frame.registers[0] = frame.variables[0];
		frame.registers[0].put("name", new StringValue());
		frame.returnRegister = 0;

		Signal signal = new Signal(Signal.Type.RETURN);
		return signal;
	}

	public void setName(String name) {
		if(name == null) {
			this.value.put("name", new NullValue());
		} else {
			this.value.put("name", new StringValue(name));
		}
	}
}

