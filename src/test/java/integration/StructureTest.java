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

import dog.lang.*;
import dog.lang.compiler.*;
import dog.lang.nodes.*;
import dog.util.Helper;

import org.junit.*;
import java.util.*;

public class StructureTest {
    
    @Test
    public void testSimple() {
    	String source = Helper.readResource("/integrations/structure.dog");
    	StackFrame frame = Helper.eval(source).get(0);

    	

    }
}
