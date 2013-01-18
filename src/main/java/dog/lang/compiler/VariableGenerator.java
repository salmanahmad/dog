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

package dog.lang.compiler;

import java.util.HashMap;

public class VariableGenerator {
	public int currentVariableIndex = -1;

	public HashMap<String, Integer> variables = new HashMap<String, Integer>();

	public boolean containsVariable(String variable) {
		return variables.containsKey(variable);
	}

	public int registerVariable(String variable) {
		return getIndexForVariable(variable);
	}

	public int getIndexForVariable(String variable) {
		if(variables.containsKey(variable)) {
			return variables.get(variable);
		} else {
			currentVariableIndex++;
			variables.put(variable, currentVariableIndex);
			return currentVariableIndex;
		}
	}

	public int variableCount() {
		return currentVariableIndex + 1;
	}
}




