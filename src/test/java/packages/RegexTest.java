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

public class RegexTest {
	@Test
	public void testMatchBooleanTrueString(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = regex.does_pattern:\"hello\"match:\"hello world\"").get(0);

		TrueValue xValue = (TrueValue)frame.getVariableNamed("x");
		Assert.assertEquals(true, xValue.getValue());
    }
	
	@Test
	public void testMatchBooleanTrueRegex(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = regex.does_pattern:\"hex*l+o\"match:\"hello world\"").get(0);

		TrueValue xValue = (TrueValue)frame.getVariableNamed("x");
		Assert.assertEquals(true, xValue.getValue());
    }
	
	@Test
	public void testMatchBooleanTrueAnchorBeginRegex(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = regex.does_pattern:\"^hex*l+o\"match:\"hello world\"").get(0);

		TrueValue xValue = (TrueValue)frame.getVariableNamed("x");
		Assert.assertEquals(true, xValue.getValue());
    }
	
	@Test
	public void testMatchBooleanFalseAnchorBeginRegex(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = regex.does_pattern:\"^hex*l+o\"match:\"ahello world\"").get(0);

		FalseValue xValue = (FalseValue)frame.getVariableNamed("x");
		Assert.assertEquals(false, xValue.getValue());
    }
	
	@Test
	public void testMatchBooleanTrueAnchorEndRegex(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = regex.does_pattern:\"world$\"match:\"hello world\"").get(0);

		TrueValue xValue = (TrueValue)frame.getVariableNamed("x");
		Assert.assertEquals(true, xValue.getValue());
    }
	
	@Test
	public void testMatchBooleanFalseAnchorEndRegex(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = regex.does_pattern:\"worl$\"match:\"ahello world\"").get(0);

		FalseValue xValue = (FalseValue)frame.getVariableNamed("x");
		Assert.assertEquals(false, xValue.getValue());
    }
	
	@Test
	public void testMatchBooleanFalseString(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = regex.does_pattern:\"hello\"match:\"goodbye world\"").get(0);

		FalseValue xValue = (FalseValue)frame.getVariableNamed("x");
		Assert.assertEquals(false, xValue.getValue());
    }
	
	@Test
	public void testMatchBooleanFalseRegex(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = regex.does_pattern:\"hel+o\"match:\"goodbye world\"").get(0);

		FalseValue xValue = (FalseValue)frame.getVariableNamed("x");
		Assert.assertEquals(false, xValue.getValue());
    }
	
	@Test
	public void testMatchIndexNoString(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = regex.with:\"ahello world\" indexes_with_pattern:\"not\"").get(0);
		
		StructureValue xValue = (StructureValue)frame.getVariableNamed("x");
		int vsize = ((HashMap<Integer, Integer>)(xValue.getValue())).size();
		Assert.assertEquals(0, vsize);
    }
	
	@Test
	public void testMatchIndexNoRegex(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = regex.with:\"ahello world\" indexes_with_pattern:\"hex+llo\"").get(0);
		
		StructureValue xValue = (StructureValue)frame.getVariableNamed("x");
		int vsize = ((HashMap<Integer, Integer>)(xValue.getValue())).size();
		Assert.assertEquals(0, vsize);
    }
	
	@Test
	public void testMatchIndexOneString(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = regex.with:\"ahello world\" indexes_with_pattern:\"hello\"").get(0);
		
		StructureValue xValue = (StructureValue)frame.getVariableNamed("x");
		int vsize = ((HashMap<Integer, Integer>)(xValue.getValue())).size();
		NumberValue nv = (NumberValue)(xValue.get(Integer.toString(0)));
		int ind0 = (int)nv.value;
		Assert.assertEquals(1, ind0);
		Assert.assertEquals(1, vsize);
    }
	
	@Test
	public void testMatchIndexOneRegex(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = regex.with:\"ahello world\" indexes_with_pattern:\"he[l]*o\"").get(0);
		
		StructureValue xValue = (StructureValue)frame.getVariableNamed("x");
		int vsize = ((HashMap<Integer, Integer>)(xValue.getValue())).size();
		NumberValue nv = (NumberValue)(xValue.get(Integer.toString(0)));
		int ind0 = (int)nv.value;
		Assert.assertEquals(1, ind0);
		Assert.assertEquals(1, vsize);
    }
	
	@Test
	public void testMatchIndexMultString(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = regex.with:\"ahello world\" indexes_with_pattern:\"l\"").get(0);

		StructureValue xValue = (StructureValue)frame.getVariableNamed("x");
		int vsize = ((HashMap<Integer, Integer>)(xValue.getValue())).size();
		NumberValue nv0 = (NumberValue)(xValue.get(Integer.toString(0)));
		int ind0 = (int)nv0.value;
		NumberValue nv1 = (NumberValue)(xValue.get(Integer.toString(1)));
		int ind1 = (int)nv1.value;
		NumberValue nv2 = (NumberValue)(xValue.get(Integer.toString(2)));
		int ind2 = (int)nv2.value;
		Assert.assertEquals(3, ind0);
		Assert.assertEquals(4, ind1);
		Assert.assertEquals(10, ind2);
		Assert.assertEquals(3, vsize);
    }
	
	@Test
	public void testMatchIndexMultRegex(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = regex.with:\"ahello world\" indexes_with_pattern:\"l[od]+\"").get(0);

		StructureValue xValue = (StructureValue)frame.getVariableNamed("x");
		int vsize = ((HashMap<Integer, Integer>)(xValue.getValue())).size();
		NumberValue nv0 = (NumberValue)(xValue.get(Integer.toString(0)));
		int ind0 = (int)nv0.value;
		NumberValue nv1 = (NumberValue)(xValue.get(Integer.toString(1)));
		int ind1 = (int)nv1.value;
		Assert.assertEquals(4, ind0);
		Assert.assertEquals(10, ind1);
		Assert.assertEquals(2, vsize);
    }
	
	@Test
	public void testMatchStringNoString(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = regex.with:\"ahello world\" indexes_with_pattern:\"not\"").get(0);
		
		StructureValue xValue = (StructureValue)frame.getVariableNamed("x");
		int vsize = ((HashMap<Integer, Integer>)(xValue.getValue())).size();
		Assert.assertEquals(0, vsize);
    }
	
	@Test
	public void testMatchStringNoRegex(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = regex.with:\"ahello world\" indexes_with_pattern:\"e[0-9]llo\"").get(0);
		
		StructureValue xValue = (StructureValue)frame.getVariableNamed("x");
		int vsize = ((HashMap<Integer, Integer>)(xValue.getValue())).size();
		Assert.assertEquals(0, vsize);
    }
	
	@Test
	public void testMatchStringOneString(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = regex.with:\"ahello world\" match_with_pattern:\"hello\"").get(0);
		
		StructureValue xValue = (StructureValue)frame.getVariableNamed("x");
		int vsize = ((HashMap<Integer, Integer>)(xValue.getValue())).size();
		StringValue nv = (StringValue)(xValue.get(Integer.toString(0)));
		String ind0 = nv.value;
		Assert.assertEquals("hello", ind0);
		Assert.assertEquals(1, vsize);
    }
	
	@Test
	public void testMatchStringOneRegex(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = regex.with:\"ahello world\" match_with_pattern:\"(^[a-z]+ll)\"").get(0);
		
		StructureValue xValue = (StructureValue)frame.getVariableNamed("x");
		int vsize = ((HashMap<Integer, Integer>)(xValue.getValue())).size();
		StringValue nv = (StringValue)(xValue.get(Integer.toString(0)));
		String ind0 = nv.value;
		Assert.assertEquals("ahell", ind0);
		Assert.assertEquals(1, vsize);
    }
	
	@Test
	public void testMatchStringMultString(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = regex.with:\"ahello world\" match_with_pattern:\"l\"").get(0);
		
		StructureValue xValue = (StructureValue)frame.getVariableNamed("x");
		int vsize = ((HashMap<Integer, Integer>)(xValue.getValue())).size();
		StringValue nv0 = (StringValue)(xValue.get(Integer.toString(0)));
		String ind0 = nv0.value;
		Assert.assertEquals("l", ind0);
		StringValue nv1 = (StringValue)(xValue.get(Integer.toString(1)));
		String ind1 = nv1.value;
		Assert.assertEquals("l", ind1);
		StringValue nv2 = (StringValue)(xValue.get(Integer.toString(2)));
		String ind2 = nv2.value;
		Assert.assertEquals("l", ind2);
		Assert.assertEquals(3, vsize);
    }
	
	@Test
	public void testMatchStringMultRegex(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = regex.with:\"ahello world\" match_with_pattern:\"[a-z]l\"").get(0);
		
		StructureValue xValue = (StructureValue)frame.getVariableNamed("x");
		int vsize = ((HashMap<Integer, Integer>)(xValue.getValue())).size();
		Assert.assertEquals(2, vsize);
		StringValue nv0 = (StringValue)(xValue.get(Integer.toString(0)));
		String ind0 = nv0.value;
		Assert.assertEquals("el", ind0);
		StringValue nv1 = (StringValue)(xValue.get(Integer.toString(1)));
		String ind1 = nv1.value;
		Assert.assertEquals("rl", ind1);
    }
	
	@Test
	public void testMatchStringMultOverlapRegex(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = regex.with:\"ahello world\" match_with_pattern:\"[a-z]+llo\"").get(0);
		
		StructureValue xValue = (StructureValue)frame.getVariableNamed("x");
		int vsize = ((HashMap<Integer, Integer>)(xValue.getValue())).size();
		Assert.assertEquals(1, vsize);
		StringValue nv0 = (StringValue)(xValue.get(Integer.toString(0)));
		String ind0 = nv0.value;
		Assert.assertEquals("ahello", ind0);
    }
	
	@Test
	public void testCaptureMatchGroupOneMatchOneGroupRegex(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = regex.with:\"ahello world\" capture_with_pattern:\"(^[a-z]+ll)o\"").get(0);
		
		StructureValue xValue = (StructureValue)frame.getVariableNamed("x");
		int vsize = ((HashMap<Integer, Integer>)(xValue.getValue())).size();
		StructureValue ind0 = (StructureValue)xValue.get("0");
		StringValue ind0s0 = (StringValue)ind0.get("0");
		String ind0s0v = ind0s0.value;
		Assert.assertEquals("ahello", ind0s0v);
		StringValue ind0s1 = (StringValue)ind0.get("1");
		String ind0s1v = ind0s1.value;
		Assert.assertEquals("ahell", ind0s1v);
		
		Assert.assertEquals(1, vsize);
    }
	
	@Test
	public void testCaptureMatchGroupOneMatchMultiGroupRegex(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = regex.with:\"ahello world\" capture_with_pattern:\"(^[a-z]+ll)(o)\"").get(0);
		
		StructureValue xValue = (StructureValue)frame.getVariableNamed("x");
		int vsize = ((HashMap<Integer, Integer>)(xValue.getValue())).size();
		StructureValue ind0 = (StructureValue)xValue.get("0");
		StringValue ind0s0 = (StringValue)ind0.get("0");
		String ind0s0v = ind0s0.value;
		Assert.assertEquals("ahello", ind0s0v);
		StringValue ind0s1 = (StringValue)ind0.get("1");
		String ind0s1v = ind0s1.value;
		Assert.assertEquals("ahell", ind0s1v);
		StringValue ind0s2 = (StringValue)ind0.get("2");
		String ind0s2v = ind0s2.value;
		Assert.assertEquals("o", ind0s2v);
		
		Assert.assertEquals(1, vsize);
    }
	
	@Test
	public void testCaptureMatchGroupMultiMatchMultiGroupRegex(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = regex.with:\"ahello world\" capture_with_pattern:\"([a-z]l)([a-z])\"").get(0);
		
		StructureValue xValue = (StructureValue)frame.getVariableNamed("x");
		int vsize = ((HashMap<Integer, Integer>)(xValue.getValue())).size();
		StructureValue ind0 = (StructureValue)xValue.get("0");
		StringValue ind0s0 = (StringValue)ind0.get("0");
		String ind0s0v = ind0s0.value;
		Assert.assertEquals("ell", ind0s0v);
		StringValue ind0s1 = (StringValue)ind0.get("1");
		String ind0s1v = ind0s1.value;
		Assert.assertEquals("el", ind0s1v);
		StringValue ind0s2 = (StringValue)ind0.get("2");
		String ind0s2v = ind0s2.value;
		Assert.assertEquals("l", ind0s2v);
		
		StructureValue ind1 = (StructureValue)xValue.get("1");
		StringValue ind1s0 = (StringValue)ind1.get("0");
		String ind1s0v = ind1s0.value;
		Assert.assertEquals("rld", ind1s0v);
		StringValue ind1s1 = (StringValue)ind1.get("1");
		String ind1s1v = ind1s1.value;
		Assert.assertEquals("rl", ind1s1v);
		StringValue ind1s2 = (StringValue)ind1.get("2");
		String ind1s2v = ind1s2.value;
		Assert.assertEquals("d", ind1s2v);
		
		Assert.assertEquals(2, vsize);
    }
	
}
