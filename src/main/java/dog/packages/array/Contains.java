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


package dog.packages.array;

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

import java.util.Arrays;
import java.util.ArrayList;

import org.apache.commons.lang3.ArrayUtils;


@Symbol("array.does:contain:")
public class Contains extends Function {

	public int getVariableCount() {
		return 2;
	}

	public int getRegisterCount() {
		return 1;
	}

	public Signal resume(StackFrame frame) {
		Value value = frame.variables[0];
		Value search = frame.variables[1];
		Value returnValue;

		if(value instanceof Array && search instanceof Object) {
			Array array = (Array)value;
			Object searchvalue = (Object)search;
			returnValue = (ArrayUtils.contains(array, searchvalue.value))?(new TrueValue()):(new FalseValue());
		} else {
			returnValue = new NullValue();
		}

		frame.registers[0] = returnValue;
		frame.returnRegister = 0;

		return new Signal(Signal.Type.RETURN);
	}
}