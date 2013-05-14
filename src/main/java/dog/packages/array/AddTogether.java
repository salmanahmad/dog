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
import dog.lang.runtime.Helper;

import dog.packages.dog.Array;

import java.util.Arrays;
import java.util.ArrayList;

import org.apache.commons.lang3.ArrayUtils;


@Symbol("array.add:and:")
public class AddTogether extends Function {

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

		if(value instanceof Array && search instanceof Array) {
			Array array1 = (Array)value;
			Array array2 = (Array)search;

			ArrayList temp1 = Helper.dogArrayAsJavaList(array1);
			ArrayList temp2 = Helper.dogArrayAsJavaList(array2);

			Object[] t1 = temp1.toArray();
			Object[] t2 = temp2.toArray();

			Object[] result = ArrayUtils.addAll(t1,t2);
			ArrayList listresult = new ArrayList(Arrays.asList(result));
			
			returnValue = Helper.javaListAsArray(listresult);
		} else {
			returnValue = new NullValue();
		}

		frame.registers[0] = returnValue;
		frame.returnRegister = 0;

		return new Signal(Signal.Type.RETURN);
	}
}