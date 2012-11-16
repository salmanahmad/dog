
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

package dog.lang.commands;

import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;
import java.lang.Math;

public class Help extends Command {
	public void usage() {
		System.out.println(this.versionString());
		System.out.println();
		System.out.println("Usage: dog COMMAND [command-specific-arguments]");
		System.out.println();
		System.out.println("List of commands, type \"dog help COMMAND\" for more details:");
		System.out.println();
    	
    	int maxLength = 0;

    	for(String name : Command.commands.keySet()) {
    		maxLength = Math.max(maxLength, name.length());
    	}

		for(String name : Command.commands.keySet()) {
			Command c = Command.commandNamed(name);
			System.out.print("  " + name);

			int remaining = maxLength - name.length();
      		remaining += 4;

	      	for(int i = 0; i < remaining; i++) {
	      		System.out.print(" ");
	      	}

	      	System.out.print("# ");
	      	System.out.print(c.description());
	      	System.out.print("\n");
		}
    
    	System.out.println();
	}

	public String description() {
		return "Show the help page for a command";
	}

	public void run(ArrayList<String> args) {
		try {
			Command command = Command.commandNamed(args.get(0));
			command.usage();
		} catch (Exception e) {
			System.out.println("Exception: " + e.toString());
			this.usage();
		}
	}
}





