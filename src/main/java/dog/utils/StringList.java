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

package dog.util;

import java.util.ArrayList;
import java.util.Arrays;

public class StringList {
	public ArrayList<String> strings;

	public StringList() {
		this.strings = new ArrayList<String>();
	}

	public StringList(String[] strings) {
		this.strings = new ArrayList<String>(Arrays.asList(strings));
	}

	public StringList(ArrayList<String> strings) {
		this.strings = strings;
	}

	public String get(int index) {
		try {
			return strings.get(index);
		} catch(Exception e) {
			return null;
		}
	}

	public void push(String string) {
		strings.add(string);
	}

	public String pop() {
		try {
			return strings.remove(strings.size() - 1);
		} catch(Exception e) {
			return null;
		}
	}

	public void unshift(String string) {
		strings.add(0, string);
	}

	public String shift() {
		try {
			return strings.remove(0);
		} catch(Exception e) {
			return null;
		}
	}
}