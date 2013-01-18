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
import java.util.Arrays;

public class Main {
	public static void main(String[] args) {
		StringList arguments = new StringList(args);
		Command command = new Command();
		command.run(arguments);
	}
}




