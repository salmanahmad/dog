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

import dog.util.Helper;
import dog.util.StringList;

import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.lang.IndexOutOfBoundsException;

public class Command {
	
	public static HashMap<String, Class<? extends Command>> commands = new LinkedHashMap<String, Class<? extends Command>>(); 
	static {
		commands.put("init", Init.class);
		commands.put("parse", Parse.class);
		commands.put("compile", Compile.class);
		commands.put("run", Run.class);
		commands.put("start", Start.class);
		commands.put("restart", Restart.class);
		commands.put("reset", Reset.class);
		commands.put("shell", Shell.class);
		commands.put("help", Help.class);
		commands.put("version", Version.class);
	}

	public static Command commandNamed(String name) {
		try {
			Class<? extends Command> klass = commands.get(name);
			if(klass != null) {
				return klass.newInstance();
			} else {
				return null;
			}
		} catch(InstantiationException e) {
			return null;
		} catch(IllegalAccessException e) {
			return null;
		}
	}

	public String name() {
		return this.getClass().getName();
	}

	public String versionString() {
 		return String.format("Dog %s (Codename: %s)", dog.lang.Version.string, dog.lang.Version.codename);
	}

	public String description() {
		return "";
	}

	public void usage() {
		System.out.println(this.versionString());
		
		String[] path = name().split("\\.");
		String name = path[path.length - 1];

		String resourceName = resourceName = name + "Usage.txt";
		String contents = Helper.readResource(this.getClass(), resourceName);

		System.out.println(contents);
	}

	public void run(StringList args) {

		String name = "";

		try {
			name = args.get(0);
		} catch (IndexOutOfBoundsException e) {
			name = "";
		}

		Command command = commandNamed(name);
		
		if(command != null) {
			args.shift();
			command.run(args);
		} else {
			Help help = new Help();
			help.usage();
		}	
	}

}





