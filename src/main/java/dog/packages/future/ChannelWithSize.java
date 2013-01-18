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
import dog.lang.NullValue;
import dog.lang.StructureValue;
import dog.lang.NumberValue;
import dog.lang.Function;
import dog.lang.Signal;
import dog.lang.StackFrame;
import dog.lang.annotation.Symbol;

@Symbol("future.channel_with_size:")
public class ChannelWithSize extends Function {

	public int getRegisterCount() {
		return 1;
	}

	public int getVariableCount() {
		return 1;
	}

	public Signal resume(StackFrame frame) {

		Value arg = frame.variables[0];

		// TODO: Logging / Exceptions or something needed here to check for parameters types

		if(arg instanceof NumberValue) {
			NumberValue size = (NumberValue)arg;
			
			StructureValue value = new StructureValue();
			value.pending = true;
			value.channelMode = true;

			value.channelSize = ((Double)size.getValue()).intValue();

			dog.lang.Future future = new dog.lang.Future(frame.getRuntime());
			future.valueId = value.getId();
			future.queueSize = value.channelSize;
			future.save();

			frame.registers[0] = value;
		} else {
			frame.registers[0] = new NullValue();
		}

		frame.returnRegister = 0;
		return new Signal(Signal.Type.RETURN);
	}
}

