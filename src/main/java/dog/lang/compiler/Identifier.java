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

package dog.lang.compiler;

import java.util.ArrayList;

public class Identifier {
	public enum Scope {
		CASCADE,
		LOCAL,
		INTERNAL,
		EXTERNAL
	}

	public Scope scope;
	public ArrayList<String> path;
}