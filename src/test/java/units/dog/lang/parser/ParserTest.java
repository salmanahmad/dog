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
}
