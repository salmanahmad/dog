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
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval(source).get(0);

		NumberValue xValue = (NumberValue)frame.getVariableNamed("x");
		Assert.assertEquals(5.5, xValue.value, 0.0);

		TrueValue yValue = (TrueValue)frame.getVariableNamed("y");
		Assert.assertEquals(TrueValue.class, yValue.getClass());
		
		NumberValue zValue = (NumberValue)frame.getVariableNamed("z");
		Assert.assertEquals(8.0, zValue.value, 0.0);
    }

    @Test
    public void testNested() {
		String source = Helper.readResource("/integrations/StructureTest/nested.dog");
		StackFrame frame = Helper.eval(source).get(0);

		NumberValue value;

		value = (NumberValue)frame.getVariableNamed("a");
		Assert.assertEquals(42.0, value.value, 0.0);

		value = (NumberValue)frame.getVariableNamed("b");
		Assert.assertEquals(42.0, value.value, 0.0);

		value = (NumberValue)frame.getVariableNamed("c");
		Assert.assertEquals(42.0, value.value, 0.0);
    }

    @Test
    public void testBuild() {
		String source = Helper.readResource("/integrations/StructureTest/build.dog");
		StackFrame frame = Helper.eval(source).get(0);

		StructureValue value = (StructureValue)frame.getVariableNamed("f");
		
		Assert.assertEquals(value.getClass().getName(), "dog.packages.universe.null$dot$file");
		Assert.assertEquals(((HashMap<Object, Value>)value.getValue()).size(), 2);
		Assert.assertEquals(value.get("name").getValue(), "foo");
		Assert.assertEquals(value.get("foo").getValue(), 7.0);
    }

    @Test
    public void testNative() {
    	String source = Helper.readResource("/integrations/StructureTest/native.dog");
    	StackFrame frame = Helper.eval(source).get(0);

    	StructureValue value = (StructureValue)frame.getVariableNamed("a");

    	Assert.assertEquals(value.getClass().getName(), "dog.packages.universe.dog$dot$date");
    	Assert.assertEquals(((HashMap<Object, Value>)value.getValue()).size(), 1);
    	Assert.assertEquals(value.get("month").getValue(), 7.0);

    }
}
