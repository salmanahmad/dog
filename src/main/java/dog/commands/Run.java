
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

import dog.util.StringList;

import java.io.File;
import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;

import org.apache.commons.io.FilenameUtils;

public class Run extends Command {
	public String description() {
		return "Compile and execute a dog program and clears the database if needed";
	}

	public void run(StringList args) {
		String name = args.get(0);

		if(FilenameUtils.isExtension(name, "dog") || FilenameUtils.isExtension(name, "bark")) {
			name = FilenameUtils.removeExtension(name);
		}
		
		String sourceFilename = name + ".dog";
		String barkFilename = name + ".bark";
		
		File sourceFile = new File(sourceFilename);
		File barkFile = new File(barkFilename);

		if(sourceFile.exists() && barkFile.exists() && (sourceFile.lastModified() > barkFile.lastModified())) {
			Restart command = new Restart();
			command.run(args);
		} else {
			if(!barkFile.exists()) {
				Compile command = new Compile();
				command.run(args);
			}

			Start command = new Start();
			command.run(args);
		}
	}
}





