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

import java.util.Arrays;
import java.util.ArrayList;
import dog.packages.dog.Array;
import java.util.SortedSet;
import java.util.TreeSet;

import org.apache.commons.lang3.ArrayUtils;

@Symbol("array.add:to:")
public class Add extends Function {

	public int getVariableCount() {
		return 2;
	}

	public int getRegisterCount() {
		return 1;
	}

	public Signal resume(StackFrame frame) {
		Value toadd = frame.variables[0];
		Value value = frame.variables[1];
		Value returnValue;


		if(toadd instanceof Object && value instanceof Array) {
			Object addobj = (Object)toadd;
			Array array = (Array)value;

			ArrayList temparray = Helper.dogArrayAsJavaList(array);
			temparray.add(addobj);
			returnValue = Helper.javaListAsArray(temparray);
		} else {
			returnValue = new NullValue();
		}

		frame.registers[0] = returnValue;
		frame.returnRegister = 0;

		return new Signal(Signal.Type.RETURN);
	}
}