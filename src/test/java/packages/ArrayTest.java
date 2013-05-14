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
import dog.packages.dog.Array;

import org.junit.*;
import java.util.*;

public class ArrayTest{
	@Test
	public void testContainsTrue(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = array.does:[1,2,3] contain:2").get(0);

		TrueValue xValue = (TrueValue)frame.getVariableNamed("x");
		Assert.assertEquals(true, xValue.getValue());
    }
    @Test
	public void testContainsFalse(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = array.does:[1,2,3,6,7,10,9] contain:8").get(0);

		TrueValue xValue = (TrueValue)frame.getVariableNamed("x");
		Assert.assertEquals(true, xValue.getValue());
    }
}

