
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
import dog.util.Helper;

import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;

public class Shell extends Command {
	public String description() {
		return "Start a shell session with a running Dog application";
	}

	public void run(StringList args) {
		Helper.eval("<eval>", "forever do;input = console.readLine: \"> \";if input == null then;return;end;dog.print: (dog.eval: input);end");
	}
}





