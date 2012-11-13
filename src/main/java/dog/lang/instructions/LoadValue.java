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

package dog.lang.instructions;

import dog.lang.Value;

public class LoadValue extends Instruction {
	public Value value;

	public LoadValue(int line, int outputRegister, Value string) {
		super(line, outputRegister);
		this.value = value;
	}

	public String toString() {
		return String.format(":load_value %s", value.toString());
	}
}

