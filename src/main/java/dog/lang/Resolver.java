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

public class Resolver {
	
	public static void linkBytecode(byte[] bytecode) {

	}

	public static void linkBark(String filepath) {

	}

	public static void linkBark(File file) {
		// You need to create your own class loader and add the file
		// to it here. You cannot add the jar file to the system class loader
	}

	public static void linkNativeCode() {

	}

	public static Object resolveSymbol(String symbol) {
		// You may need to check the Resolver's class loader for packages
		// that have been loaded dynmically...
	}

	public static String encodeSymbol(String symbol) {

	}

	public static String decodeSymbol(String symbol) {

	}
	
}


