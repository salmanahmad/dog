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
		NONE,
		CALL,
		SCHEDULE,
		PAUSE,
		STOP,
		EXIT
	}

	public Type type;
	public StackFrame stackFrame = null;
}