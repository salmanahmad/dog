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

public class Symbol {
	public enum Kind {
		FUNCTION,
		TYPE,
		CONSTANT
	}

	public String name;
	public Kind kind;

	public Symbol(String name, Kind kind) {
		this.name = name;
		this.kind = kind;
	}
}

