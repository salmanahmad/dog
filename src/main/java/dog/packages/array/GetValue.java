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
import dog.lang.NumberValue;
import dog.lang.NullValue;
import dog.lang.Function;
import dog.lang.Signal;
import dog.lang.Resolver;
import dog.lang.StackFrame;
import dog.lang.annotation.Symbol;

import java.util.Arrays;
import java.util.ArrayList;

import java.lang.String;

import org.apache.commons.lang3.StringUtils;


@Symbol("array.get_value_at:")
public class GetValue extends Function {

	public int getVariableCount() {
		return 1;
	}

	public int getRegisterCount() {
		return 1;
	}

	public Signal resume(StackFrame frame) {
		Value index = frame.variables[0];
		Value returnValue;

		if(index instanceof NumberValue) {
			NumberValue theIndex = (NumberValue)index;
			int intIndex = (int)theIndex.value;
			try{
				returnValue = new StringValue(Character.toString(array.value.charAt(intIndex)));
			}catch(Exception e){
				returnValue = new NullValue();
			}
		} else {
			returnValue = new NullValue();
		}

		frame.registers[0] = returnValue;
		frame.returnRegister = 0;

		return new Signal(Signal.Type.RETURN);
	}
}