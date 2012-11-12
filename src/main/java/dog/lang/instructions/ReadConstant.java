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

import dog.lang.compiler.Identifier;

public class ReadConstant extends Instruction {
	Identifier type;

	public ReadConstant(int outputRegister, Identifier type) {
		this(-1, outputRegister, type);
	}

	public ReadConstant(int line, int outputRegister, Identifier type) {
		super(line, outputRegister);
		this.type = type;
	}
}
