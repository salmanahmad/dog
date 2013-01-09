
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

import dog.lang.Runtime;
import dog.util.StringList;


import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;

public class Reset extends Command {
	public String description() {
		return "Clears the database associated with the dog application";
	}

	public void run(StringList args) {
		String applicationName = args.get(0);
		
		try {
			dog.lang.Runtime runtime = new dog.lang.Runtime(applicationName);
			runtime.reset();
		} catch(Exception e) {
			e.printStackTrace();
			throw new RuntimeException("Could not create Dog runtime.");
		}
	}
}





