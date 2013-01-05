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

public class OperatorsTest {
    
    @Test
    public void testSimpleFunction() {
    	String source = Helper.readResource("/integrations/operators.dog");
    	StackFrame frame = Helper.eval(source).get(0);
    	
    	Assert.assertTrue(frame.getVariableNamed("t") instanceof TrueValue);
    	Assert.assertTrue(frame.getVariableNamed("f") instanceof FalseValue);

    }
}
