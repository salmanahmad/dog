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
    public void testUppercaseSimple() {
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.upper_case: \"hello\"").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("HELLO", xValue.value);
    }
	
	@Test
	public void testSubstringSimple(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.substring: \"hello\" starting: 0 ending:2").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("he", xValue.value);
    }
	
	@Test
	public void testChompSimple(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.chomp: \"hello\\n\"").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("hello", xValue.value);
    }
	
	@Test
	public void testContainsTrue(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.contains: \"hello\" substring: \"el\"").get(0);

		TrueValue xValue = (TrueValue)frame.getVariableNamed("x");
		Assert.assertEquals(true, xValue.getValue());
    }
	
	@Test
	public void testDeleteWhitespaceSimple(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.delete_whitespace: \"h e  l l o \" ").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("hello", xValue.value);
    }
	
	@Test
	public void testDifferenceSimple(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.difference: \"hello\" from: \"hellotest\"").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("test", xValue.value);
    }
	
	@Test
	public void testEndsWithTrue(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.ends_with: \"hello\" suffix:\"lo\"").get(0);

		TrueValue xValue = (TrueValue)frame.getVariableNamed("x");
		Assert.assertEquals(true, xValue.getValue());
    }
	
	@Test
	public void testEndsWithFalse(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.ends_with: \"hello\" suffix:\"yo\"").get(0);

		FalseValue xValue = (FalseValue)frame.getVariableNamed("x");
		Assert.assertEquals(false, xValue.getValue());
    }
	
	@Test
	public void testIndexOfFound(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.index_of: \"hello\" search:\"l\"").get(0);

		NumberValue xValue = (NumberValue)frame.getVariableNamed("x");
		Assert.assertEquals(2.0, xValue.getValue());
    }
	
	@Test
	public void testIndexOfNotFound(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.index_of: \"hello\" search:\"k\"").get(0);

		NumberValue xValue = (NumberValue)frame.getVariableNamed("x");
		Assert.assertEquals(-1.0, xValue.getValue());
    }
	
	@Test
	public void testIsAllLowerCaseTrue(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.is_all_lower_case: \"hello\"").get(0);

		TrueValue xValue = (TrueValue)frame.getVariableNamed("x");
		Assert.assertEquals(true, xValue.getValue());
    }
	
	@Test
	public void testIsAllLowerCaseFalse(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.is_all_lower_case: \"Hello\"").get(0);

		FalseValue xValue = (FalseValue)frame.getVariableNamed("x");
		Assert.assertEquals(false, xValue.getValue());
    }
	
	@Test
	public void testIsAllUpperCaseTrue(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.is_all_upper_case: \"HELLO\"").get(0);

		TrueValue xValue = (TrueValue)frame.getVariableNamed("x");
		Assert.assertEquals(true, xValue.getValue());
    }
	
	@Test
	public void testIsAllUpperCaseFalse(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.is_all_upper_case: \"Hello\"").get(0);

		FalseValue xValue = (FalseValue)frame.getVariableNamed("x");
		Assert.assertEquals(false, xValue.getValue());
    }
	
	@Test
	public void testIsAlphaTrue(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.is_alpha: \"hello\"").get(0);

		TrueValue xValue = (TrueValue)frame.getVariableNamed("x");
		Assert.assertEquals(true, xValue.getValue());
    }
	
	@Test
	public void testIsAlphaFalse(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.is_alpha: \"Hello.\"").get(0);

		FalseValue xValue = (FalseValue)frame.getVariableNamed("x");
		Assert.assertEquals(false, xValue.getValue());
    }
	
	@Test
	public void testIsAlphanumericTrue(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.is_alphanumeric: \"hello123\"").get(0);

		TrueValue xValue = (TrueValue)frame.getVariableNamed("x");
		Assert.assertEquals(true, xValue.getValue());
    }
	
	@Test
	public void testIsAlphanumericFalse(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.is_alphanumeric: \"Hello.123\"").get(0);

		FalseValue xValue = (FalseValue)frame.getVariableNamed("x");
		Assert.assertEquals(false, xValue.getValue());
    }
	
	@Test
	public void testIsAlphanumericSpaceTrue(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.is_alphanumeric_space: \"hello123 \"").get(0);

		TrueValue xValue = (TrueValue)frame.getVariableNamed("x");
		Assert.assertEquals(true, xValue.getValue());
    }
	
	@Test
	public void testIsAlphanumericSpaceFalse(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.is_alphanumeric_space: \"Hello.123  \"").get(0);

		FalseValue xValue = (FalseValue)frame.getVariableNamed("x");
		Assert.assertEquals(false, xValue.getValue());
    }
	
	@Test
	public void testIsAlphaSpaceTrue(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.is_alpha_space: \"hello \"").get(0);

		TrueValue xValue = (TrueValue)frame.getVariableNamed("x");
		Assert.assertEquals(true, xValue.getValue());
    }
	
	@Test
	public void testIsAlphaSpaceFalse(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.is_alpha_space: \"Hello123  \"").get(0);

		FalseValue xValue = (FalseValue)frame.getVariableNamed("x");
		Assert.assertEquals(false, xValue.getValue());
    }
	
	@Test
	public void testIsBlankEmpty(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.is_blank: \"\"").get(0);

		TrueValue xValue = (TrueValue)frame.getVariableNamed("x");
		Assert.assertEquals(true, xValue.getValue());
    }
	
	@Test
	public void testIsBlankSpace(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.is_blank: \"  \"").get(0);

		TrueValue xValue = (TrueValue)frame.getVariableNamed("x");
		Assert.assertEquals(true, xValue.getValue());
    }
	
	@Test
	public void testIsBlankFalse(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.is_blank: \"Hello.123  \"").get(0);

		FalseValue xValue = (FalseValue)frame.getVariableNamed("x");
		Assert.assertEquals(false, xValue.getValue());
    }
	
	@Test
	public void testLastIndexOfSimple(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.last_index_of: \"hello\" search:\"l\"").get(0);

		NumberValue xValue = (NumberValue)frame.getVariableNamed("x");
		Assert.assertEquals(3.0, xValue.getValue());
    }
	
	@Test
	public void testLeftSimple(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.left: \"hello\" length:3").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("hel", xValue.getValue());
    }
	
	@Test
	public void testLeftPadSimple(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.left_pad: \"hello\" length:8").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("   hello", xValue.getValue());
    }
	
	@Test
	public void testLengthSimple(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.length: \"hello123 \"").get(0);

		NumberValue xValue = (NumberValue)frame.getVariableNamed("x");
		Assert.assertEquals(9.0, xValue.getValue());
    }
	
	@Test
    public void testLowercaseSimple() {
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.lower_case: \"HELLo\"").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("hello", xValue.value);
    }
	
	@Test
    public void testRemoveSimple() {
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.remove: \"hello\" substring:\"hel\"").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("lo", xValue.value);
    }
	
	@Test
    public void testRepeatSimple() {
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.repeat: \"hello\" times:3").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("hellohellohello", xValue.value);
    }
	
	@Test
    public void testReplaceFoundOnce() {
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.replace: \"hello\" search:\"hel\" replace_with:\"yo\"").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("yolo", xValue.value);
    }
	
	@Test
    public void testReplaceFoundMultiple() {
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.replace: \"hello\" search:\"l\" replace_with:\"yo\"").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("heyoyoo", xValue.value);
    }
	
	@Test
    public void testReplaceNotFound() {
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.replace: \"hello\" search:\"null\" replace_with:\"yo\"").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("hello", xValue.value);
    }
	
	@Test
    public void testReplaceOnceFound() {
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.replace_once: \"hello\" search:\"l\" replace_with:\"yo\"").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("heyolo", xValue.value);
    }
	
	@Test
    public void testReplaceOnceNotFound() {
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.replace_once: \"hello\" search:\"null\" replace_with:\"yo\"").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("hello", xValue.value);
    }
	
	@Test
    public void testReverseSimple() {
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.reverse: \"hello\"").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("olleh", xValue.value);
    }
	
	@Test
	public void testRightSimple(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.right: \"hello\" length:3").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("llo", xValue.getValue());
    }
	
	@Test
	public void testRightPadSimple(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.right_pad: \"hello\" length:8").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("hello   ", xValue.getValue());
    }
	
	@Test
	public void testStartsWithTrue(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.starts_with: \"hello\" prefix:\"hel\"").get(0);

		TrueValue xValue = (TrueValue)frame.getVariableNamed("x");
		Assert.assertEquals(true, xValue.getValue());
    }
	
	@Test
	public void testStartsWithFalse(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.starts_with: \"hello\" prefix:\"yo\"").get(0);

		FalseValue xValue = (FalseValue)frame.getVariableNamed("x");
		Assert.assertEquals(false, xValue.getValue());
    }
	
	@Test
	public void testStripSimple(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.strip: \"   hello    \"").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("hello", xValue.getValue());
    }
}
