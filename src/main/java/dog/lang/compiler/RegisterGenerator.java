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

import java.util.Stack;

public class RegisterGenerator {
	public int largestRegister = -1;

	Stack<Integer> availableRegisters = new Stack<Integer>();

	public int generate() {
		int generatedRegister;

		if(availableRegisters.empty()) {
			largestRegister++;
			generatedRegister = largestRegister;
		} else {
			generatedRegister = availableRegisters.pop();
		}

		return generatedRegister;
	}

	public void release(int register) {
		if(register != -1) {
			availableRegisters.push(register);
		}
	}
}




