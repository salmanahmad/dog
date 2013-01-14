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

public class Util {
	public static String typeAsString(Value v) {
		if(v instanceof NullValue) {
			return "dog.null";
		} else if(v instanceof TrueValue) {
			return "dog.boolean";
		} else if(v instanceof FalseValue) {
			return "dog.boolean";
		} else if(v instanceof NumberValue) {
			return "dog.number";
		} else if(v instanceof StringValue) {
			return "dog.string";
		} else {
			String type = "dog.structure";
			if(!(v.getClass().equals(StructureValue.class) || v.getClass().equals(Type.class))) {
            	type = Resolver.decodeSymbol(Resolver.convertJavaClassNameToJVMClassName(v.getClass().getName()));
            }

            return type;
        }
	}
}


