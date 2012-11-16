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

import java.util.*;
import java.io.*;

import java.nio.channels.FileChannel;
import java.nio.MappedByteBuffer;
import java.nio.charset.Charset;

public class Helper {
	
	private static String readFile(String path) {
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

	public static String readResource(String path) {
		try {
			InputStream in = Helper.class.getResourceAsStream(path);
        	String content = new Scanner(in).useDelimiter("\\A").next();
        	return content;
		} catch(Exception e) {
			return null;
		}
	}
}