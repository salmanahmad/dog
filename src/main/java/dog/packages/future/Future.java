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

package dog.packages.future;

import dog.lang.Value;
import dog.lang.Type;
import dog.lang.Signal;
import dog.lang.StackFrame;
import dog.lang.annotation.Symbol;

@Symbol("future.future")
public class Future extends Type {
	public Signal resume(StackFrame frame) {
		frame.returnRegister = 0;

		frame.registers[0] = frame.variables[0];

		Signal signal = new Signal(Signal.Type.RETURN, frame);
		return signal;
	}
}

