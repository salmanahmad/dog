
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

public class Version extends Command {
	public String description() {
		return "Show the dog version";
	}

	public void run(StringList args) {
		System.out.println(super.versionString());
	}
}





