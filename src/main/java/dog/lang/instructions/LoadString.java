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

public class LoadString extends Instruction {
	public String string;

	public LoadString(int line, int outputRegister, String string) {
		super(line, outputRegister);
		this.string = string;
	}
}

