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

import dog.lang.compiler.Bark;
import dog.lang.compiler.Symbol;

import java.io.File;

public class Resolver extends ClassLoader {
		
	public Class loadClass(byte[] b) {
		Class klass = null;

		try {
			klass = defineClass(null, b, 0, b.length);
		} catch(Exception e) {
			e.printStackTrace();
	    	System.exit(1);
		}

		return klass;
	}
	
	public void linkBytecode(byte[] bytecode) {
		loadClass(bytecode);
	}

	public void linkBark(String filepath) {
		// Create a File object and call linkBark(File).
	}

	public void linkBark(File file) {
		// You need to create your own class loader and add the file
		// to it here. You cannot add the jar file to the system class loader
	}

	public void linkBark(Bark bark) {
		for(Symbol symbol : bark.symbols) {
			linkBytecode(symbol.bytecode);
		}
	}

	public void linkNativeCode() {
		// This method will use reflections to find all of the classes that are 
		// annotated and create a subclass that is dog runtime friendly.
	}

	public Object resolveSymbol(String symbol) {
		// You may need to check the Resolver's class loader for packages
		// that have been loaded dynamically...
		symbol = Resolver.encodeSymbol(symbol);
		return null;
	}

	public static String encodeSymbol(String symbol) {
		return null;
	}

	public static String decodeSymbol(String symbol) {
		return null;
	}
	
}


