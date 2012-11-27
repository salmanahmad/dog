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

import dog.lang.*;
import dog.lang.parser.*;
import dog.lang.compiler.*;
import dog.lang.runtime.*;
import dog.lang.nodes.*;

import java.util.*;
import java.io.*;
import java.nio.channels.FileChannel;
import java.nio.MappedByteBuffer;
import java.nio.charset.Charset;
import java.net.URL;

import java.util.concurrent.atomic.AtomicInteger;

public class Helper {
	
	public static AtomicInteger uniqueCounter = new AtomicInteger();

	public static int uniqueNumber() {
		return uniqueCounter.getAndIncrement();
	}

	public static String readFile(String path) {
	  	FileInputStream stream = null;

	  	try {
	  		stream = new FileInputStream(new File(path));
	    	FileChannel fc = stream.getChannel();
	    	MappedByteBuffer bb = fc.map(FileChannel.MapMode.READ_ONLY, 0, fc.size());
	    	return Charset.defaultCharset().decode(bb).toString();
	  	} catch(Exception e) {
	  		return null;
	  	} finally {
	  		try {
	  			stream.close();	
	  		} catch(Exception e) {
	  			return null;
	  		}
	    	
	  	}
	}

	public static String[] getResourceListing(Class klass, String path) {
      try {
		URL dirURL = klass.getResource(path);
      	return new File(dirURL.toURI()).list();
      } catch(Exception e) {
		return null;
      }
  	}


  	public static String[] getResourceListing(String path) {
		return getResourceListing(Helper.class, path);
    }


	public static String readResource(Class klass, String path) {
		try {
			InputStream in = klass.getResourceAsStream(path);
        	String content = new Scanner(in).useDelimiter("\\A").next();
        	return content;
		} catch(Exception e) {
			return null;
		}
	}

	public static String readResource(String path) {
		return readResource(Helper.class, path);
	}

	public static StackFrame eval(String source) {
		Parser parser = new Parser();
		Nodes program = parser.parse(source);

    	dog.lang.compiler.Compiler compiler = new dog.lang.compiler.Compiler();
    	compiler.processNodes(program);
    	Bark bark = compiler.compile();

    	Resolver resolver = new Resolver();
    	resolver.linkBark(bark);

    	dog.lang.runtime.Runtime runtime = new dog.lang.runtime.Runtime(resolver);
    	return runtime.invoke("null.@root");
	}

}