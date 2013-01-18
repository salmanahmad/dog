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

public class Signal {
	public enum Type {
		RETURN,
		INVOKE,
		SCHEDULE,
		PAUSE,
		STOP,
		EXIT
	}

	public Signal() {

	}

	public Signal(Type type) {
		this.type = type;
	}

	public Signal(Type type, StackFrame frame) {
		this.type = type;
		this.stackFrame = frame;
	}

	public Type type = Type.RETURN;
	public StackFrame stackFrame = null;
}