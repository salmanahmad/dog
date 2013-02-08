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

	public Identifier() {

	}

	public Identifier(Scope s, ArrayList<String> p) {
		this.scope = s;
		this.path = p;
	}

	public boolean equals(Identifier other) {
		if(this.scope != other.scope) {
			return false;
		}

		if(this.path.size() == other.path.size()) {
			for(int i = 0; i < path.size(); i++) {
				if(!this.path.get(i).equals(other.path.get(i))) {
					return false;
				}
			}
		} else {
			return false;
		}

		return true;
	}

	public Scope scope = Scope.CASCADE;
	public ArrayList<String> path = new ArrayList<String>();
}