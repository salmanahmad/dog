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

public class SimpleTest {
    
    @Test
    public void testSimpleFunction() {
    	String source = Helper.readResource("/integrations/simple.dog");
    	StackFrame frame = Helper.eval("dog_unit_tests", source).get(0);

    	NumberValue value = (NumberValue)frame.getVariableNamed("i");
    	Assert.assertEquals(120.0, value.value, 0.0);

    }
}
