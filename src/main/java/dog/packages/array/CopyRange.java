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
import dog.lang.NumberValue;
import dog.lang.FalseValue;
import dog.lang.Function;
import dog.lang.Signal;
import dog.lang.Resolver;
import dog.lang.StackFrame;
import dog.lang.annotation.Symbol;
import dog.lang.runtime.Helper;
import java.util.Arrays;
import java.util.ArrayList;
import dog.packages.dog.Array;
import org.apache.commons.lang3.ArrayUtils;

@Symbol("array.copy:from:to:")
public class CopyRange extends Function {

	public int getVariableCount() {
		return 3;
	}

	public int getRegisterCount() {
		return 1;
	}

	public Signal resume(StackFrame frame) {
		Value value = frame.variables[0];
		Value start = frame.variables[1];
		Value end = frame.variables[2];
		Value returnValue;

		if(value instanceof Array && start instanceof NumberValue && end instanceof NumberValue) {
			Array array = (Array)value;
			NumberValue s = (NumberValue) start;
			NumberValue e = (NumberValue) end;

			int startintinclusive = (int) s.value;
			int endintexclusive = (int) e.value;

			ArrayList temparray = Helper.dogArrayAsJavaList(array);
			Object[] tarray = temparray.toArray();
			Object[] result = ArrayUtils.subarray(tarray, startintinclusive, endintexclusive);
			
			ArrayList resultarray = new ArrayList(Arrays.asList(result));

			returnValue = Helper.javaListAsArray(resultarray);
		} else {
			returnValue = new NullValue();
		}

		frame.registers[0] = returnValue;
		frame.returnRegister = 0;

		return new Signal(Signal.Type.RETURN);
	}
}