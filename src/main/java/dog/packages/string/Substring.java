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

package dog.packages.string;

import dog.lang.Value;
import dog.lang.StringValue;
import dog.lang.NullValue;
import dog.lang.NumberValue;
import dog.lang.Function;
import dog.lang.Signal;
import dog.lang.Resolver;
import dog.lang.StackFrame;
import dog.lang.annotation.Symbol;

import java.util.Arrays;
import java.util.ArrayList;

import org.apache.commons.lang3.StringUtils;


@Symbol("string.substring:starting:ending:")
public class Substring extends Function {

	public int getVariableCount() {
		return 3;
	}

	public int getRegisterCount() {
		return 1;
	}
	
	public Signal resume(StackFrame frame) {
		Value value = frame.variables[0];
		Value starting = frame.variables[1];
		Value ending = frame.variables[2];
		Value returnValue;

		if(value instanceof StringValue && starting instanceof NumberValue && ending instanceof NumberValue) {
			StringValue string = (StringValue)value;
			NumberValue stringstart = (NumberValue)starting;
			NumberValue stringend = (NumberValue)ending;
			returnValue = new StringValue(StringUtils.substring(string.value, (int)stringstart.value, (int)stringend.value));
		} else {
			returnValue = new NullValue();
		}

		frame.registers[0] = returnValue;
		frame.returnRegister = 0;

		return new Signal(Signal.Type.RETURN);
	}
}