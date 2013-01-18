
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

package dog.commands;

import dog.lang.Bark;
import dog.lang.Resolver;
import dog.lang.Runtime;
import dog.util.StringList;

import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;

import org.apache.commons.io.FilenameUtils;

public class Start extends Command {
	public boolean restart = false;

	public String description() {
		return "Resume executing a Dog source file or application";
	}

	public void run(StringList args) {
		try {
			Resolver resolver = new Resolver();
			String startUpSymbol = null;
			String applicationName = null;
			String applicationPath = null;

			for(String arg : args.strings) {
				String originalArg = arg;

				if(FilenameUtils.isExtension(arg, "dog") || FilenameUtils.isExtension(arg, "bark")) {
					arg = FilenameUtils.removeExtension(arg);
				}

				arg += ".bark";

				Bark bark = new Bark(new FileInputStream(arg));
				resolver.linkBark(bark);

				if(startUpSymbol == null) {
					startUpSymbol = bark.startUpSymbol;
					applicationName = FilenameUtils.removeExtension(arg);
					applicationPath = FilenameUtils.getFullPath(new File(originalArg).getAbsolutePath());
				}
			}

			Runtime runtime = null;
			
			try {
				runtime = new Runtime(applicationName, applicationPath, resolver);
			} catch(Exception e) {
				throw new RuntimeException("Could not create runtime.");
			}

			if(this.restart) {
				runtime.restart(startUpSymbol);
			} else {
				runtime.start(startUpSymbol);
			}
		} catch (FileNotFoundException e) {
			System.out.println("An error took place when setting up the runtime.");
			e.printStackTrace();
		}
	}
}





