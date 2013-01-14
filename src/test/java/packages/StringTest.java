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

public class StringTest {
    
    @Test
    public void testSimple() {
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.upper_case: \"hello\"").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("HELLO", xValue.value);
    }
}
