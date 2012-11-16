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
import dog.lang.parser.grammar.*;
import dog.lang.nodes.*;
import dog.lang.compiler.Compiler;

import org.antlr.runtime.RecognitionException;

public class ParserTest {
    
    @Test
    public void testSimpleFunction() {
        Parser parser = new Parser();
        Compiler compiler = new Compiler();
        
        Nodes program = parser.parse("5 + (5 + 10) + 11 + 14");
        compiler.processNodes(program);
        System.out.println(compiler.compile());

    }


    @Test
    public void testAssignByte() {
        Parser parser = new Parser();
        Compiler compiler = new Compiler();
        
        Nodes program = parser.parse("i = 5 + 5 + 10 + 11 + 14");
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
        parser.parse("{ 5 = 5, foo = 7}");
    }

    @Test
    public void testCall() {
        Parser parser = new Parser();
        
        Nodes program = parser.parse("read_file: 5 with_encoding: 7");

    }

    @Test
    public void testAccess() throws RecognitionException {
        Parser parser = new Parser();

        parser.parse("foo['bar' + 6]");
        parser.parse("foo['bar' + 6]['foo']['bar']");
        parser.parse("foo[6]");
        parser.parse("local foo[6]");
        parser.parse("external foo[6]");
        parser.parse("internal foo[6]");

        try { parser.parse("internal internal"); Assert.fail(); } catch (Exception e) {}
        try { parser.parse("external external"); Assert.fail(); } catch (Exception e) {}
    }

    @Test
    public void testAssignment() throws RecognitionException {
        Parser parser = new Parser();

        parser.parse("i = j = k = 5");
        parser.parse("i = 0");
        parser.parse("i = 1");
        parser.parse("i = -1");
        parser.parse("i = 1.1");
        parser.parse("i = -1.1");
        parser.parse("i = true");
        parser.parse("i = false");
        parser.parse("i = \"Foo bar\"");
        parser.parse("i = 'Foo bar'");
        parser.parse("i = {'key'='value'}");
        parser.parse("i.j = 8") ;
        parser.parse("i[i] = {'key'='value'}");
        parser.parse("i[0] = {'key'='value'}");
        parser.parse("i['string'] = {'key'='value'}");
        parser.parse("i[j[k]][l] = {'key'='value'}");
        parser.parse("i.j.k.l = {'key'='value'}");
    }

    @Test
    public void testCollection() throws RecognitionException {
        Parser parser = new Parser();
        parser.parse("define collection users");
        parser.parse("define collection users;");
    }

    @Test
    public void testComment() throws RecognitionException {
        Parser parser = new Parser();
        parser.parse("  \t # comments");
        parser.parse("# comments");
        parser.parse("1+2 # comments");
        parser.parse("1+2 # comments\n\n\n");
        parser.parse("\n\n\n  1+2 # comments\n\n\n");
    }


}
