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

import java.util.ArrayList;

public class Bark {
	public String startUpSymbol = null;
	public ArrayList<byte[]> symbols;

	public Bark(String startUpSymbol, ArrayList<byte[]> symbols) {
		this.startUpSymbol = startUpSymbol;
		this.symbols = symbols;
	}
}