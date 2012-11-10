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

package dog.lang.nodes;

import dog.lang.compiler.Symbol;
import dog.lang.instructions.Signal;

public class Stop extends Node {
	public void compile(Symbol symbol) {
		Signal instruction = new Signal(this.line, "stop");
		symbol.instructions.add(instruction);
		symbol.currentOutputRegister = -1;
	}
}


