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
import dog.lang.TrueValue;
import dog.lang.FalseValue;
import dog.lang.Function;
import dog.lang.Signal;
import dog.lang.Resolver;
import dog.lang.StackFrame;
import dog.lang.annotation.Symbol;

import dog.packages.dog.Array;

import java.util.Arrays;
import java.util.ArrayList;

import org.apache.commons.lang3.StringUtils;


@Symbol("string.with:split_with:")
public class Split extends Function {

	public int getVariableCount() {
		return 2;
	}

	public int getRegisterCount() {
		return 1;
	}
	
	public Signal resume(StackFrame frame) {
		Value value = frame.variables[0];
		Value separator = frame.variables[1];
		Value returnValue;

		if(value instanceof StringValue && separator instanceof StringValue) {
			StringValue string = (StringValue)value;
			StringValue separate = (StringValue)separator;
			String[] splitarray = StringUtils.split(string.value, separate.value);
			returnValue = new Array();
			for (int i=0; i<splitarray.length; i++){
				returnValue.put(i, new StringValue(splitarray[i]));
			}
		} else {
			returnValue = new NullValue();
		}

		frame.registers[0] = returnValue;
		frame.returnRegister = 0;

		return new Signal(Signal.Type.RETURN);
	}
}