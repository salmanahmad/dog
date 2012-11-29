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

import java.util.jar.*;
import java.util.ArrayList;
import java.io.File;
import java.io.OutputStream;

import org.objectweb.asm.ClassReader;

public class Bark {

	public static final String DOG_STARTUP_SYMBOL = "Dog-Startup-Symbol";

	public String startUpSymbol = null;
	public ArrayList<byte[]> symbols;

	public Bark(String startUpSymbol, ArrayList<byte[]> symbols) {
		this.startUpSymbol = startUpSymbol;
		this.symbols = symbols;
	}

	public Bark(File barkFile) {

	}

	public void writeToFile(OutputStream stream) {
		try {
			Manifest manifest = new Manifest();
			manifest.getMainAttributes().put(Attributes.Name.MANIFEST_VERSION, "1.0");
			manifest.getMainAttributes().put(new Attributes.Name(DOG_STARTUP_SYMBOL), startUpSymbol);

			JarOutputStream target = new JarOutputStream(stream, manifest);
			
			for(byte[] b : symbols) {
				ClassReader reader = new ClassReader(b);

				JarEntry entry = new JarEntry(reader.getClassName());
				target.putNextEntry(entry);
				target.write(b, 0, b.length);
				target.closeEntry();
			}

			target.close();
		} catch(Exception e) {
			System.out.println(e);
			e.printStackTrace();
		}
		
	}
}