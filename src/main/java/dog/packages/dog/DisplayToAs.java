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
import dog.lang.StringValue;
import dog.lang.StructureValue;
import dog.lang.Function;
import dog.lang.Signal;
import dog.lang.StackFrame;
import dog.lang.annotation.Symbol;

import java.util.Map;

@Symbol("dog.display:to:as:")
public class DisplayToAs extends Function {

	public int getRegisterCount() {
		return 0;
	}

	public int getVariableCount() {
		return 3;
	}

	public Signal resume(StackFrame frame) {
		StackFrame currentFrame = frame.parentStackFrame();

		Value value = frame.variables[0];
		Value routing = frame.variables[1];
		Value identifier = frame.variables[2];

		if(identifier instanceof StringValue) {
			Map<String, Value> meta = currentFrame.getMetaData();
			
			if(meta.get("displays") == null) {
				meta.put("displays", new StructureValue());
			}

			StructureValue displays = (StructureValue)meta.get("displays");
			StructureValue display = new StructureValue();
			display.put("value", value);
			display.put("routing", routing);
			display.put("identifier", identifier);

			displays.put(((StringValue)identifier).value, display);
		}

		return new Signal(Signal.Type.RETURN);
	}
}

