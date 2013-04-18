
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

import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;

public class Restart extends Command {
	public String description() {
		return "Compile and execute a dog program after clearing the database";
	}
	
	public void run(StringList args) {
		Compile compile = new Compile();
		compile.run(Start.commandLineFiles(args));

		Start start = new Start();
		start.restart = true;
		start.run(args);
	}
}





