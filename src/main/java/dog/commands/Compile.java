
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

import dog.lang.Resolver;
import dog.lang.parser.Parser;
import dog.lang.compiler.Bark;
import dog.lang.compiler.Compiler;
import dog.lang.compiler.Symbol;
import dog.lang.nodes.*;

import dog.util.Helper;
import dog.util.StringList;

import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;

public class Compile extends Command {
	public String description() {
		return "Compile a Dog source file or application";
	}

	public void run(StringList args) {
		boolean dump = false;

		if (args.get(0).equals("--show-bytecode")) {
			dump = true;
			args.shift();
		} else {
			dump = false;
		}

		Resolver resolver = new Resolver();
		Compiler compiler = new Compiler(resolver);
		Parser parser = new Parser();

		for(String arg : args.strings) {
			String source_filename = arg;
        	String source_code = "";
        	
        	if(!source_filename.endsWith(".dog")) {
				source_filename += ".dog";
        	}

        	String source_string = Helper.readFile(source_filename);
        	
        	if(source_string == null) {
        		System.out.println("Could not open file: " + source_filename + ".");
        		System.exit(1);
        	}

        	Nodes ast = parser.parse(source_string);
        	compiler.processNodes(ast);
		}

		Bark bark = compiler.compile();

		if(dump) {
			System.out.println("Dog Bytecode:");
			System.out.println("-------------");

			for(Symbol s : bark.symbols) {
				System.out.println(s.toDogBytecodeString());
			}

			System.out.println("JVM Bytecode:");
			System.out.println("-------------");

			for(Symbol s : bark.symbols) {
				System.out.println(s.toJVMBytecodeString());
			}
		} else {

		}
	}
}




