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
import dog.lang.TrueValue;
import dog.lang.FalseValue;
import dog.lang.Function;
import dog.lang.Signal;
import dog.lang.StackFrame;
import dog.lang.annotation.Symbol;

@Symbol("future.is_value:from_future:")
public class IsValueFromFuture extends Function {

	public int getRegisterCount() {
		return 1;
	}

	public int getVariableCount() {
		return 2;
	}

	public Signal resume(StackFrame frame) {
		Value value = frame.variables[0];
		Value future = frame.variables[1];

		Value returnValue = null;

		Class listenerClass = frame.getRuntime().getResolver().classForSymbol("dog.listener");
		if(listenerClass.isAssignableFrom(future.getClass())) {
			future = future.get("channel");
		}

		if(future.getId().equals(value.futureId) || future.getId().equals(value.getId())) {
			returnValue = new TrueValue();
		} else {
			returnValue = new FalseValue();
		}

		frame.registers[0] = returnValue;
		frame.returnRegister = 0;

		return new Signal(Signal.Type.RETURN);
	}
}

