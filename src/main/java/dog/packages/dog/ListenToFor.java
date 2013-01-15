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
import dog.lang.NumberValue;
import dog.lang.StringValue;
import dog.lang.StructureValue;
import dog.lang.Function;
import dog.lang.Signal;
import dog.lang.StackFrame;
import dog.lang.annotation.Symbol;

import java.util.Map;

@Symbol("dog.listen_to:for:")
public class ListenToFor extends Function {

	public int getRegisterCount() {
		return 1;
	}

	public int getVariableCount() {
		return 2;
	}

	public Signal resume(StackFrame frame) {
		Value routing = frame.variables[0];
		Value identifier = frame.variables[1];

		if(identifier instanceof StringValue) {
			StringValue stringIdentifier = (StringValue)identifier;

			switch(frame.programCounter) {
				case 0:
					StackFrame invocation = new StackFrame("future.channel_with_size:", frame.getRuntime().getResolver(), new Value[] { new NumberValue(0) });

					frame.returnRegister = 0;
					frame.programCounter++;

					return new Signal(Signal.Type.INVOKE, invocation);
				case 1:
					StackFrame currentFrame = frame.parentStackFrame();
					Map<String, Value> meta = currentFrame.getMetaData();

					if(meta.get("listens") == null) {
						meta.put("listens", new StructureValue());
					}

					StructureValue listens = (StructureValue)meta.get("listens");
					StructureValue listen = new StructureValue();

					listen.put("channel", frame.registers[frame.returnRegister]);
					listen.put("routing", routing);
					listen.put("identifier", stringIdentifier);

					listens.put(stringIdentifier.value, listen);
				default:
					// Pass through the return value that is already in the returnRegister.
					return new Signal(Signal.Type.RETURN);
			}

		} else {
			return new Signal(Signal.Type.RETURN);
		}
	}
}

