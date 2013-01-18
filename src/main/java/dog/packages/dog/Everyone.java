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
import dog.lang.Type;
import dog.lang.Signal;
import dog.lang.StackFrame;
import dog.lang.annotation.Symbol;

@Symbol("dog.everyone")
public class Everyone extends Type {

	public int getRegisterCount() {
		return 1;
	}

	public Signal resume(StackFrame frame) {
		frame.registers[0] = frame.variables[0];
		frame.returnRegister = 0;
		return new Signal(Signal.Type.RETURN);
	}
}

