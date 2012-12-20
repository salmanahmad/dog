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

@Symbol("dog.date")
public class Date extends Type {

	public int getRegisterCount() {
		return 1;
	}

	public Signal resume(StackFrame frame) {
		try {
			frame.registers[0] = this.getClass().newInstance();
			frame.returnRegister = 0;
		} catch (InstantiationException e) {

		} catch (IllegalAccessException e) {
			
		}

		Signal signal = new Signal(Signal.Type.RETURN, frame);
		return signal;
	}
}

