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

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;

import dog.util.Helper;
import dog.lang.parser.*;
import dog.lang.parser.grammar.*;
import dog.lang.nodes.*;
import dog.lang.compiler.Compiler;

import org.antlr.runtime.RecognitionException;

public class ParserTest {

    @Test
    public void testResourceExamples() throws Exception {
        String[] paths = Helper.getResourceListing("/examples/");
        for(String path : paths) {
            path = "/examples/" + path;
            try {
                Parser parser = new Parser();
                String source = Helper.readResource(path);
                Nodes program = parser.parse(source);
            } catch(Exception e) {
                System.out.println("Failed on test: " + path);
                throw e;
            }
        }
    }


    @Test
    public void testEmpty() {
        Parser parser = new Parser();
        Nodes program = parser.parse("");
    }


    @Test
    public void testSimpleFunction() {
        Parser parser = new Parser();
        Compiler compiler = new Compiler();
        
        Nodes program = parser.parse("5 + (5 + 10) + 11 + 14");
        compiler.processNodes(program);
        
        //System.out.println(compiler.compile());
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
        
        //System.out.println(compiler.compile());

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

    @Test
    public void testExpression() throws RecognitionException {
        Parser parser = new Parser();

        parser.parse("!true");
        parser.parse("5 + 5");
        parser.parse("5 + 5 + 5 + 5");
        parser.parse("5 + 5 + foo['hi']['world'] + 5");
        parser.parse("5 + 5 + (foo['hi']['world']) + 5");
        parser.parse("5 + 5 + (((foo['hi']['world']))) + 5");
        parser.parse("(5 + 5) / 2");
        parser.parse("5 + 5 / 2");
        parser.parse("5 / 2 + 5");
        parser.parse("(5) + (5 + 5) + 5");
        parser.parse("foo");
        parser.parse("foo.bar") ;
        parser.parse("foo.bar.baz");
        parser.parse("foo.bar.baz.poo");
        parser.parse("foo.bar['hi']");
        parser.parse("foo[bar]");
        parser.parse("foo[bar][baz]");
        parser.parse("foo[bar[bar]]");
        parser.parse("(foo[bar])[baz]");
        parser.parse("foo[bar][baz[foo][bar]][poo]");
        parser.parse("!true");
        parser.parse("!x");
        parser.parse("!!x");
        parser.parse("! true");
        parser.parse("! x");
        parser.parse("! ! x");
    }

    @Test
    public void testLiteral() throws RecognitionException {
        Parser parser = new Parser();

        parser.parse("0");
        parser.parse("1");
        parser.parse("13");

        parser.parse("0.0");
        parser.parse("1.0");
        parser.parse("3.14");
        
        parser.parse("-0");
        parser.parse("-1");
        parser.parse("-13");

        parser.parse("-0.0");
        parser.parse("-1.0");
        parser.parse("-3.14");

        parser.parse("true");
        parser.parse("false");

        parser.parse("'Hello, World!'");
        parser.parse("\"Hello, World!\"");
        parser.parse("'Hello, \" World!'");
        parser.parse("\"Hello, \\\" World!\"");
        parser.parse("\"Hello, \\\\ \\\" World!\"");
        try { parser.parse("'Hello, \\' World!'"); Assert.fail(); } catch (Exception e) {}
        
        parser.parse("[]");
        parser.parse("[1]");
        parser.parse("[1,]");
        parser.parse("[1,2,3]");
        parser.parse("[1,2.0,-3]");
        parser.parse("[1   ,    2.0, -3]");
        parser.parse("[1,'Foo Bar']");
        parser.parse("[1,'Foo Bar', true, false]");
        parser.parse("[[1],'Foo Bar', true, false]");
        parser.parse("[[[[[[3.14]]]]]]");
        parser.parse("[{'key'=5}]");
        
        try { parser.parse("[1items,]"); Assert.fail(); } catch (Exception e) {}
        
        parser.parse("{'key'='value'}");
        parser.parse("{\"key\"='value'}");
        parser.parse("{'key'=1,}");
        parser.parse("{'key'=1}");
        parser.parse("{'key'=true}");
        parser.parse("{'key'=-4.5}");
        parser.parse("{'key'=1, 'key2'='value'}");
        parser.parse("{'key'=[1,2,3]}");
        parser.parse("{'key'=[[1]]}");
        parser.parse("{'key'=[[1,2,true]]}");
        parser.parse("{'key'={'key'='value'}}");
        parser.parse("{  'key' =   1   , 'key2'  =  'value'  }");
        parser.parse("{\n\t'key'=1,\n\t'key2'='value'\n}");
    }

    @Test
    public void testScope() throws RecognitionException {
        Parser parser = new Parser();

        parser.parse("i = external foo.bar.baz");
        parser.parse("i = internal foo.bar.baz");
        parser.parse("i = local foo.bar.baz");
    }


    @Test
    public void testSpaces() throws RecognitionException {
        Parser parser = new Parser();
        
        parser.parse("");
        parser.parse("    ");
        parser.parse("\n");
        parser.parse(" \n");
        parser.parse(" \n\n  \n\n   ");
        parser.parse(" \n   \n  \n\n\n     \n\n\n   \n\n    \n");
        parser.parse("\n\n  \n\n  i = 'foobar'  \n\n");
        parser.parse("\n\n  \n\n  i = 'foobar'\n5+5  \n\n");
        parser.parse("\n\n  \n\n  i = 'foobar'\n5 +  5  \n\n");
        parser.parse("i = 'foobar'");
        parser.parse("i = 'foobar'\n");
        parser.parse(" # comments");
        parser.parse("# comments");
        parser.parse("1+2# comments");
        parser.parse("\n\n1+2# comments\n\n");
    }


    @Test
    public void testWait() throws RecognitionException {
        Parser parser = new Parser();

        parser.parse("wait on 5");
        parser.parse("spawn create: matrix height: 500 width: 500");
        
        try { parser.parse("spawn 5 + 5"); Assert.fail(); } catch (Exception e) {}
    
        parser.parse("stop");
        parser.parse("pause");
        parser.parse("exit");
    }

}
