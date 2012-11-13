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

public class Jump extends Instruction {
	int offset;

	public Jump(int offset) {
		this(-1, offset);
	}

	public Jump(int line, int offset) {
		super(line);
		this.offset = offset;	
	}

	public String toString() {
		return String.format(":jump %d", offset);
	}
}

