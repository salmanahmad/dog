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

package dog.lang.runtime;

import dog.lang.*;

import java.util.List;
import java.util.ArrayList;

public class Runtime {

	Resolver resolver;

	public Runtime(Resolver resolver) {
		this.resolver = resolver;
	}

	public StackFrame invoke(String symbol) {
		return this.invoke(symbol, new ArrayList<Value>(), null);
	}

	public StackFrame invoke(String symbol, List<Value> arguments) {
		return this.invoke(symbol, arguments, null);
	}

	public StackFrame invoke(String symbol, List<Value> arguments, StackFrame parentStackFrame) {
		Continuable symbolInstance = (Continuable)resolver.resolveSymbol(symbol);
		StackFrame frame = null;

		this.schedule(frame);
		this.resume();

		return frame;
	}

	public void schedule(StackFrame frame) {

	}

	public void resume() {

	}
}

