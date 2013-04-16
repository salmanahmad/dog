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

package dog.lang;

import dog.lang.Bark;
import dog.lang.compiler.Symbol;

import java.util.Set;
import java.util.ArrayList;
import java.util.Arrays;
import java.io.File;
import java.lang.annotation.Annotation;

import org.reflections.*;
import org.reflections.scanners.*;
import org.reflections.util.*;
import com.google.common.base.Predicate;

import org.objectweb.asm.*;

public class Resolver extends ClassLoader implements Opcodes {

	ArrayList<dog.lang.Symbol> linkedSymbols = new ArrayList<dog.lang.Symbol>();

	public Resolver() {
		super();
		linkNativeCode();
	}

	// Creates a child resolver that delegates symbol lookups to its
	// parent.
	public Resolver(Resolver parent){
		super(parent);
	}

	public Resolver getParentResolver(){
		if (Resolver.class.isInstance(this.getParent())){
			return (Resolver)this.getParent();
		}
		return null;
	}

	public Class loadClass(byte[] b) {
		Class klass = null;

		try {
			klass = defineClass(null, b, 0, b.length);

			dog.lang.Symbol.Kind kind = null;

			if(Constant.class.isAssignableFrom(klass)) {
				kind = dog.lang.Symbol.Kind.CONSTANT;
			}

			if(Function.class.isAssignableFrom(klass)) {
				kind = dog.lang.Symbol.Kind.FUNCTION;
			}

			if(Type.class.isAssignableFrom(klass)) {
				kind = dog.lang.Symbol.Kind.TYPE;
			}

			dog.lang.Symbol symbol = new dog.lang.Symbol(Resolver.decodeSymbol(Resolver.convertJavaClassNameToJVMClassName(klass.getName())), kind);
			linkedSymbols.add(symbol);
		} catch(Exception e) {
			e.printStackTrace();
	    	System.exit(1);
		}
		
		return klass;
	}
	
	public void linkBytecode(byte[] bytecode) {
		loadClass(bytecode);
	}

	public void linkBark(Bark bark) {
		for(byte[] bytecode : bark.symbols) {
			linkBytecode(bytecode);
		}
	}

	protected void linkNativeCode() {
		Reflections reflections = new Reflections(new ConfigurationBuilder()
		     .filterInputsBy(new FilterBuilder().include(FilterBuilder.prefix("dog")))
		     .setUrls(ClasspathHelper.forJavaClassPath())
		);

        Set<Class<?>> allClasses = reflections.getTypesAnnotatedWith(dog.lang.annotation.Symbol.class);

        for (Class<?> klass : allClasses) {
        	linkNativeCode(klass);
        }
	}

	public void linkNativeCode(Class<?> klass) {
    	dog.lang.annotation.Symbol symbol = klass.getAnnotation(dog.lang.annotation.Symbol.class);
		
		if(symbol == null) {
			return;
		}

		String className = Resolver.convertJavaClassNameToJVMClassName(klass.getCanonicalName());
		String dogSymbolName = Resolver.encodeSymbol(symbol.value());

		ClassWriter cw = new ClassWriter(ClassWriter.COMPUTE_MAXS);
		MethodVisitor mv;

		cw.visit(V1_5, ACC_PUBLIC + ACC_SUPER, dogSymbolName, null, className, null);

		mv = cw.visitMethod(ACC_PUBLIC, "<init>", "()V", null, null);
		mv.visitCode();
		mv.visitVarInsn(ALOAD, 0);
		mv.visitMethodInsn(INVOKESPECIAL, className, "<init>", "()V");
		mv.visitInsn(RETURN);
		mv.visitMaxs(1, 1);
		mv.visitEnd();

		cw.visitEnd();

		this.linkBytecode(cw.toByteArray());
	}

	public Object resolveSymbol(String symbol) {
		try {
			symbol = Resolver.convertJVMClassNameToJavaClassName(Resolver.encodeSymbol(symbol));
			Class klass = this.loadClass(symbol);
			return klass.newInstance();
		} catch (ClassNotFoundException e) {
			throw new RuntimeException("Ahh: Could not find: " + symbol);
		} catch (InstantiationException e) {
			throw new RuntimeException("Ahh: 1");
		} catch (IllegalAccessException e) {
			throw new RuntimeException("Ahh: 1");
		}
	}

	public Class classForSymbol(String symbol) {
		try {
			symbol = Resolver.convertJVMClassNameToJavaClassName(Resolver.encodeSymbol(symbol));
			Class klass = this.loadClass(symbol);
			return klass;
		} catch(Exception e) {
			return null;
		}
	}

	public boolean containsSymbol(String name) {
		ArrayList<dog.lang.Symbol> list = searchForSymbolsStartingWith(name);

		if(list.size() == 1 && list.get(0).name.equals(name)) {
			return true;
		} else {
			return false;
		}
	}

	public dog.lang.Symbol searchForSymbol(String name) {
		ArrayList<dog.lang.Symbol> symbols = searchForSymbolsStartingWith(name);

		for(dog.lang.Symbol symbol : symbols) {
			if(symbol.name.equals(name)) {
				return symbol;
			}
		}

		return null;
	}

	public ArrayList<dog.lang.Symbol> searchForSymbolsStartingWith(String name) {
		ArrayList<dog.lang.Symbol> list = new ArrayList<dog.lang.Symbol>();

		Reflections reflections = new Reflections(new ConfigurationBuilder()
		     .filterInputsBy(new FilterBuilder().include(FilterBuilder.prefix("dog")))
		     .setUrls(ClasspathHelper.forJavaClassPath())
		);

		Set<Class<? extends Continuable>> classes = reflections.getSubTypesOf(Continuable.class);

        for (Class<?> c : classes) {
        	String symbolName = Resolver.decodeSymbol(Resolver.convertJavaClassNameToJVMClassName(c.getName()));
        	if(symbolName.startsWith(name)) {
        		dog.lang.Symbol.Kind kind = null;

        		if(Constant.class.isAssignableFrom(c)) {
        			kind = dog.lang.Symbol.Kind.CONSTANT;
        		}

        		if(Function.class.isAssignableFrom(c)) {
        			kind = dog.lang.Symbol.Kind.FUNCTION;
        		}

        		if(Type.class.isAssignableFrom(c)) {
        			kind = dog.lang.Symbol.Kind.TYPE;
        		}

				list.add(new dog.lang.Symbol(symbolName, kind));
			}
        }

		for (dog.lang.Symbol linkedSymbol : this.getLinkedSymbols(name)){
			list.add(linkedSymbol);
		}

		Resolver parent = this.getParentResolver();
		if (parent != null){
			for (dog.lang.Symbol linkedSymbol : parent.getLinkedSymbols(name)){
				list.add(linkedSymbol);
			}
		}

		return list;
	}

	public ArrayList<dog.lang.Symbol> getLinkedSymbols(String namePrefix){
		ArrayList<dog.lang.Symbol> list = new ArrayList<dog.lang.Symbol>();
        for(dog.lang.Symbol linkedSymbol: linkedSymbols) {
        	if(linkedSymbol.name.startsWith(namePrefix)) {
				list.add(linkedSymbol);
        	}
        }
		return list;
	}

	public static String convertJavaClassNameToJVMClassName(String name) {
		return name.replace(".", "/");
	}

	public static String convertJVMClassNameToJavaClassName(String name) {
		return name.replace("/", ".");
	}

	public static String encodeSymbol(String symbol) {
		// Dots represent package scoping. 
		symbol = symbol.replace(".", "$dot$");

		// Colons represent named-parameters
		symbol = symbol.replace(":", "$colon$");
		
		// Hash marks represent nested symbol definitions
		symbol = symbol.replace("#", "$hash$");

		// Used for top-level scope code and is not "defined"
		symbol = symbol.replace("@root", "$root$");

		// Used for anonymous functions, most notably with "on each"
		symbol = symbol.replace("@anonymous", "$anonymous$");

		return "dog/packages/universe/" + symbol;
	}

	public static String decodeSymbol(String symbol) {
		// Dots represent package scoping. 
		symbol = symbol.replace("$dot$", ".");

		// Colons represent named-parameters
		symbol = symbol.replace("$colon$", ":");
		
		// Hash marks represent nested symbol definitions
		symbol = symbol.replace("$hash$", "#");

		// Used for top-level scope code and is not "defined"
		symbol = symbol.replace("$root$", "@root");

		// Used for anonymous functions, most notably with "on each"
		symbol = symbol.replace("$anonymous$", "@anonymous");

		if(symbol.startsWith("dog/packages/universe/")) {
			return symbol.substring("dog/packages/universe/".length());
		} else {
			return symbol;
		}
	}
}


