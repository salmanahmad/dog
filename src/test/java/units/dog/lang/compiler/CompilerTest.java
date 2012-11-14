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

import dog.lang.*;
import dog.lang.compiler.*;
import dog.lang.nodes.*;

public class CompilerTest {
    
    @Test
    public void testSimpleFunction() {
        Nodes program = new Nodes(new ArrayList(Arrays.asList(
            new FunctionDefinition(
                "add:with:", 
                new ArrayList(Arrays.asList("a", "b")), 
                new Nodes(new ArrayList(Arrays.asList(
                    new Assign(
                        new ArrayList(Arrays.asList("c")),
                        new Operation(
                            new Access(Identifier.Scope.LOCAL, new ArrayList(Arrays.asList("a"))),
                            new Access(Identifier.Scope.LOCAL, new ArrayList(Arrays.asList("b"))),
                            "+"
                        )
                    ),
                    new Return(
                        new Access(
                            Identifier.Scope.LOCAL,
                            new ArrayList(Arrays.asList("c"))
                        )
                    )
                )))
            )
        )));

        dog.lang.compiler.Compiler c = new dog.lang.compiler.Compiler();
        c.processNodes(program);
        String bytecode = c.compile();
        System.out.println(bytecode);
    }
}
