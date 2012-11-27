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
		return null;
	}

	public int getRegisterCount() {
		return 0;
	}

	public int getVariableCount() {
		return 0;
	}

	public Signal resume(StackFrame stack) {
		return null;
	}
}

