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

package dog.lang;

import java.util.HashMap;

public class Type extends StructureValue implements Continuable {
	
	public HashMap<String, Integer> getVariableTable() {
		return new HashMap<String, Integer>();
	}

	public int getRegisterCount() {
		return 0;
	}

	public int getVariableCount() {
		return 1;
	}

	public Signal resume(StackFrame stack) {
		return new Signal(Signal.Type.RETURN, stack);
	}

	public void initialize() {
		// This is a method that you could consider using for
		// custom subclasses of types. The problem with resume
		// is that it requires a Dog runtime. The nice thing about
		// initialize is that if you are just creating a dummy structure
		// and want to use it from, you can call initialize directly withing
		// schedule a call to resume(). 
	}
}

