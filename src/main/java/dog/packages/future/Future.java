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
import dog.lang.StructureValue;
import dog.lang.Function;
import dog.lang.Signal;
import dog.lang.StackFrame;
import dog.lang.annotation.Symbol;




@Symbol("future.future")
public class Future extends Function {

	public int getRegisterCount() {
		return 1;
	}

	public Signal resume(StackFrame frame) {
		StructureValue value = new StructureValue();
		value.pending = true;
		value.channelMode = false;
		value.channelSize = 0;

		dog.lang.Future future = new dog.lang.Future(frame.getRuntime());
		future.valueId = value.getId();
		future.queueSize = 0;
		future.save();

		frame.registers[0] = value;
		frame.returnRegister = 0;

		Signal signal = new Signal(Signal.Type.RETURN, frame);
		return signal;
	}
}

