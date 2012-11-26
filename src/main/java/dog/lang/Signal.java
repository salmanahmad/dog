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
		CALL,
		SCHEDULE,
		PAUSE,
		STOP,
		EXIT,
		NONE
	}

	public Signal() {

	}

	public Signal(Type type, StackFrame frame) {
		this.type = type;
		this.stackFrame = frame;
	}

	public Type type = Type.NONE;
	public StackFrame stackFrame = null;
}