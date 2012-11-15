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


import org.junit.*;
import java.util.*;

import dog.lang.parser.*;
import dog.lang.nodes.*;
import dog.lang.compiler.Compiler;

public class ParserTest {
    
    @Test
    public void testSimpleFunction() {
        Parser parser = new Parser();
        Compiler compiler = new Compiler();
        
        Nodes program = parser.parse("5 + 5 + 10 + 11 + 14");
        compiler.processNodes(program);
        System.out.println(compiler.compile());

    }

    @Test
    public void testString() {
        Parser parser = new Parser();
        Compiler compiler = new Compiler();
        
        Nodes program = parser.parse("\"Hello, \\\" Worlrd\" + \"Foo\"");
        compiler.processNodes(program);
        System.out.println(compiler.compile());

    }

    @Test
    public void testArray() {
        Parser parser = new Parser();
        
        Nodes program = parser.parse("[5,4,3,2,1]");

    }

    @Test
    public void testStructure() {
        Parser parser = new Parser();
        
        Nodes program = parser.parse("{ 5 = 5, foo = 7}");

    }
}
