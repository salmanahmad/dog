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

public class Scope {
	public int start;
	public int end;
	public String label;
	public int offsetFromEnd;
	public int returnRegister;

	public String toString() {
		return "Scope: " + start + " to " + end;
	}
}