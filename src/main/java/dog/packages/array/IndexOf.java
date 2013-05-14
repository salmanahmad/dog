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
import dog.lang.NumberValue;
import dog.lang.TrueValue;
import dog.lang.FalseValue;
import dog.lang.Function;
import dog.lang.Signal;
import dog.lang.Resolver;
import dog.lang.StackFrame;
import dog.lang.annotation.Symbol;
import dog.lang.runtime.Helper;
import dog.packages.dog.Array;
import java.util.Arrays;
import java.util.ArrayList;

import org.apache.commons.lang3.ArrayUtils;


@Symbol("array.index_of:in:")
public class IndexOf extends Function {

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

		if(value instanceof Object && search instanceof Array) {
			Object tosearch = (Object)value;
			Array array = (Array)search;

			ArrayList temparray = Helper.dogArrayAsJavaList(array);
			Object[] tarray = temparray.toArray();
			int result = ArrayUtils.indexOf(tarray, tosearch);
			double convertedresult = (double) result;

			returnValue = new NumberValue(convertedresult);
		} else {
			returnValue = new NullValue();
		}

		frame.registers[0] = returnValue;
		frame.returnRegister = 0;

		return new Signal(Signal.Type.RETURN);
	}
}