
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
import dog.lang.parser.Parser;
import dog.lang.compiler.Compiler;
import dog.lang.compiler.CompileError;
import dog.lang.compiler.Symbol;
import dog.lang.nodes.*;
import dog.util.Helper;
import dog.util.StringList;

import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;
import java.io.File;
import java.io.FileOutputStream;
import org.apache.commons.io.FilenameUtils;

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
			String sourceFilename = arg;

			if(FilenameUtils.isExtension(sourceFilename, "dog") || FilenameUtils.isExtension(sourceFilename, "bark")) {
				sourceFilename = FilenameUtils.removeExtension(sourceFilename);
			}

        	sourceFilename += ".dog";

        	String sourceString = Helper.readFile(sourceFilename);
        	
        	if(sourceString == null) {
        		System.out.println("Could not open file: " + sourceFilename + ".");
        		System.exit(1);
        	}

        	Nodes ast = parser.parse(sourceString);
        	compiler.addCompilationUnit(ast, sourceFilename);
		}

		try {
		    compiler.compile();
		} catch(CompileError e) {
		    System.out.println("Compiler error at " + e.file + ":" + e.line + ": " + e.getMessage());
		    System.exit(-1);
		}

		if(dump) {
			System.out.println("Dog Bytecode:");
			System.out.println("-------------");

			for(Symbol s : compiler.getSymbols()) {
				System.out.println(s.toDogBytecodeString());
			}

			System.out.println("JVM Bytecode:");
			System.out.println("-------------");

			for(Symbol s : compiler.getSymbols()) {
				//System.out.println(s.toJVMBytecodeString());
			}
		} else {
			try {
				String name = FilenameUtils.removeExtension(args.strings.get(0));
				name += ".bark";

				compiler.getBark().writeToFile(new FileOutputStream(name));
			} catch(Exception e) {
				System.out.println("An error took place when writing the bark file to disk.");
			}
		}
	}
}




