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
import java.io.InputStream;
import java.io.FileOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.io.IOException;

import org.objectweb.asm.ClassReader;
import org.apache.commons.io.IOUtils;

public class Bark {

	public static final String DOG_STARTUP_SYMBOL = "Dog-Startup-Symbol";

	public String startUpSymbol = null;
	public ArrayList<byte[]> symbols;

	public Bark(String startUpSymbol, ArrayList<byte[]> symbols) {
		this.startUpSymbol = startUpSymbol;
		this.symbols = symbols;
	}

	public Bark(InputStream stream) {
		symbols = new ArrayList<byte[]>();
		try {
			JarInputStream target = new JarInputStream(stream);
			this.startUpSymbol = (String)target.getManifest().getMainAttributes().get(new Attributes.Name(DOG_STARTUP_SYMBOL));

			JarEntry entry;
			byte[] buffer = new byte[4096];

			while ((entry = target.getNextJarEntry()) != null) {
				ByteArrayOutputStream bytecode = new ByteArrayOutputStream();

				while ( true ) {				            
					int nRead = target.read(buffer, 0, buffer.length);
					if ( nRead <= 0 ) {
						break;
					}

					bytecode.write(buffer, 0, nRead);
				}

				symbols.add(bytecode.toByteArray());
			}
		} catch(Exception e) {
			e.printStackTrace();
		}
	}

	public void writeClassesToDirectory(String targetDirectory) throws FileNotFoundException, IOException {
		for(byte[] b : symbols) {
			ClassReader reader = new ClassReader(b);
			String fileName = reader.getClassName() + ".class";
			
			File file = new File(targetDirectory, fileName);
			file.getParentFile().mkdirs();

			FileOutputStream output = new FileOutputStream(file);
			IOUtils.write(b, output);
		}	
	}

	public void writeToFile(OutputStream stream) {
		try {
			Manifest manifest = new Manifest();
			manifest.getMainAttributes().put(Attributes.Name.MANIFEST_VERSION, "1.0");
			manifest.getMainAttributes().put(new Attributes.Name(DOG_STARTUP_SYMBOL), startUpSymbol);

			JarOutputStream target = new JarOutputStream(stream, manifest);
			
			for(byte[] b : symbols) {
				ClassReader reader = new ClassReader(b);
				JarEntry entry = new JarEntry(reader.getClassName() + ".class");
				target.putNextEntry(entry);
				target.write(b, 0, b.length);
				target.closeEntry();
			}

			target.close();
		} catch(Exception e) {
			System.out.println(e);
		}
		
	}
}