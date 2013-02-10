
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
import dog.lang.parser.ParseError;
import dog.lang.parser.LexError;
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

	Parser parser;
	Compiler compiler;

	void loadFile(String sourceFilename){
		try{
			if(FilenameUtils.isExtension(sourceFilename, "dog") || FilenameUtils.isExtension(sourceFilename, "bark")) {
				sourceFilename = FilenameUtils.removeExtension(sourceFilename);
			}

			sourceFilename += ".dog";

			String sourceString = Helper.readFile(sourceFilename);

			if(sourceString == null) {
				throw new ParseError("Could not open file");
			}
			Nodes ast = this.parser.parse(sourceString);
			if (ast == null){
				throw new ParseError("File is empty.");
			}
			this.compiler.addCompilationUnit(ast, sourceFilename);
		} catch (ParseError e){
			throw new ParseError("in " + sourceFilename + ": " + e.getMessage());
		} catch (LexError e){
			throw new LexError("in " + sourceFilename + ": " + e.getMessage());
		}
	}

	void dumpByteCode(){
		System.out.println("Dog Bytecode:");
		System.out.println("-------------");

		for(Symbol s : this.compiler.getSymbols()) {
			System.out.println(s.toDogBytecodeString());
		}

		System.out.println("JVM Bytecode:");
		System.out.println("-------------");

		for(Symbol s : this.compiler.getSymbols()) {
			//System.out.println(s.toJVMBytecodeString());
		}
	}

	String barkFileName(StringList args){
		String name = FilenameUtils.removeExtension(args.strings.get(0));
		return name + ".bark";
	}

	String jarFileName(StringList args){
		String name = FilenameUtils.removeExtension(args.strings.get(0));
		return name + ".jar";
	}

	void saveBarkFile(String name){
		try {
			this.compiler.getBark().writeToFile(new FileOutputStream(name));
		} catch(Exception e) {
			System.out.println("An error took place when writing the bark file to disk.");
		}
	}

	public void run(StringList args) {
		boolean dump = false;
		boolean useJar = false;

		StringList remainingArgs = new StringList(new String[] {});

		for(String arg : args.strings) {
			if(arg.startsWith("--")) {
				if(arg.equals("--jar")) {
					useJar = true;
					continue;
				} if(arg.equals("--show-bytecode")) {
					dump = true;
					continue;
				}
			}

			remainingArgs.strings.add(arg);
		}

		this.compiler = new Compiler(new Resolver());
		this.parser = new Parser();

		try {
			for(String arg : remainingArgs.strings) {
				this.loadFile(arg);
			}
			this.compiler.compile();
			if(dump) {
				this.dumpByteCode();
			} else {
				if(useJar) {
					this.saveBarkFile(this.jarFileName(remainingArgs));
				} else {
					this.saveBarkFile(this.barkFileName(remainingArgs));
				}
			}
			return;
		} catch(CompileError e) {
			System.out.println("Compiler error at " + e.file + ":" + e.line + ": " + e.getMessage());
		} catch(ParseError e){
			System.out.println("Parse error " + e.getMessage());
		} catch(LexError e){
			System.out.println("Lex error " + e.getMessage());
		}
		System.exit(1);
	}
}
