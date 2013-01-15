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
import dog.lang.Function;
import dog.lang.Signal;
import dog.lang.StackFrame;
import dog.lang.annotation.Symbol;

@Symbol("dog.display:to:as:")
public class DisplayToAs extends Function {

	public int getRegisterCount() {
		return 0;
	}

	public int getVariableCount() {
		return 2;
	}

	public Signal resume(StackFrame frame) {
		return new Signal(Signal.Type.RETURN);
	}
}

