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

public class StringTest {
	@Test
	public void testCharAtSimple(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.with:\"hello\"character_at_index:2").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("l", xValue.value);
    }
	
	@Test
	public void testCharAtOOB(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.with:\"hello\"character_at_index:7").get(0);

		NullValue xValue = (NullValue)frame.getVariableNamed("x");
		Assert.assertNull(xValue.getValue());
    }
	
	@Test
	public void testChompSimple(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.chomp: \"hello\\n\"").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("hello", xValue.value);
    }
	
	@Test
	public void testChompNoDiff(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.chomp: \"hello\"").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("hello", xValue.value);
    }
	
	@Test
	public void testContainsTrue(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.does: \"hello\" contain: \"el\"").get(0);

		TrueValue xValue = (TrueValue)frame.getVariableNamed("x");
		Assert.assertEquals(true, xValue.getValue());
    }
	
	@Test
	public void testContainsFalse(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.does: \"hello\" contain: \"le\"").get(0);

		FalseValue xValue = (FalseValue)frame.getVariableNamed("x");
		Assert.assertEquals(false, xValue.getValue());
    }
	
	@Test
	public void testContainsTrueMultiple(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.does: \"hello\" contain: \"l\"").get(0);

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
	public void testDeleteWhitespaceNoDiff(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.delete_whitespace: \"hello\" ").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("hello", xValue.value);
    }
	
	@Test
	public void testDifferenceSimple(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.difference_between: \"hello\" and: \"hellotest\"").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("test", xValue.value);
    }
	
	@Test
	public void testDifferenceMore(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.difference_between: \"hellotest\" and: \"hello\"").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("", xValue.value);
    }
	
	@Test
	public void testDifferenceSame(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.difference_between: \"hello\" and: \"hello\"").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("", xValue.value);
    }
	
	@Test
	public void testEndsWithTrue(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.does: \"hello\" end_with:\"lo\"").get(0);

		TrueValue xValue = (TrueValue)frame.getVariableNamed("x");
		Assert.assertEquals(true, xValue.getValue());
    }
	
	@Test
	public void testEndsWithFalse(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.does: \"hello\" end_with:\"ll\"").get(0);

		FalseValue xValue = (FalseValue)frame.getVariableNamed("x");
		Assert.assertEquals(false, xValue.getValue());
    }
	
	@Test
	public void testIndexOfFound(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.with:\"hello\" index_of: \"h\"").get(0);

		NumberValue xValue = (NumberValue)frame.getVariableNamed("x");
		Assert.assertEquals(0.0, xValue.getValue());
    }
	
	@Test
	public void testIndexOfNotFound(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.with:\"hello\" index_of: \"k\"").get(0);

		NumberValue xValue = (NumberValue)frame.getVariableNamed("x");
		Assert.assertEquals(-1.0, xValue.getValue());
    }
	
	@Test
	public void testIndexOfMultiple(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.with:\"hello\" index_of: \"l\"").get(0);

		NumberValue xValue = (NumberValue)frame.getVariableNamed("x");
		Assert.assertEquals(2.0, xValue.getValue());
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
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.is_alphanumeric_or_space: \"hello123 \"").get(0);

		TrueValue xValue = (TrueValue)frame.getVariableNamed("x");
		Assert.assertEquals(true, xValue.getValue());
    }
	
	@Test
	public void testIsAlphanumericSpaceFalse(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.is_alphanumeric_or_space: \"Hello.123  \"").get(0);

		FalseValue xValue = (FalseValue)frame.getVariableNamed("x");
		Assert.assertEquals(false, xValue.getValue());
    }
	
	@Test
	public void testIsAlphaSpaceTrue(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.is_alpha_or_space: \"hello \"").get(0);

		TrueValue xValue = (TrueValue)frame.getVariableNamed("x");
		Assert.assertEquals(true, xValue.getValue());
    }
	
	@Test
	public void testIsAlphaSpaceFalse(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.is_alpha_or_space: \"Hello123  \"").get(0);

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
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.with:\"hello\" last_index_of:\"e\"").get(0);

		NumberValue xValue = (NumberValue)frame.getVariableNamed("x");
		Assert.assertEquals(1.0, xValue.getValue());
    }
	
	@Test
	public void testLastIndexOfMultiple(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.with:\"hello\" last_index_of:\"l\"").get(0);

		NumberValue xValue = (NumberValue)frame.getVariableNamed("x");
		Assert.assertEquals(3.0, xValue.getValue());
    }
	
	@Test
	public void testLeftSimple(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.with:\"hello\" left_string_of_length:3").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("hel", xValue.getValue());
    }
	
	@Test
	public void testLeftTooLarge(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.with:\"hello\" left_string_of_length:7").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("hello", xValue.getValue());
    }
	
	@Test
	public void testLeftPadSimple(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.with:\"hello\" left_pad_with_length:8").get(0);

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
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.with:\"hello\" remove_substring: \"hel\"").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("lo", xValue.value);
    }
	
	@Test
    public void testRemoveNotIn() {
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.with:\"hello\" remove_substring: \"nan\"").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("hello", xValue.value);
    }
	
	@Test
    public void testRepeatSimple() {
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.with:\"hello\" repeat:3").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("hellohellohello", xValue.value);
    }
	
	@Test
    public void testReplaceFoundOnce() {
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.with:\"hello\" replace_all: \"hel\" with:\"yo\"").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("yolo", xValue.value);
    }
	
	@Test
    public void testReplaceFoundMultiple() {
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.with:\"hello\" replace_all: \"l\" with:\"yo\"").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("heyoyoo", xValue.value);
    }
	
	@Test
    public void testReplaceNotFound() {
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.with:\"hello\" replace_all: \"nope\" with:\"yo\"").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("hello", xValue.value);
    }
	
	@Test
    public void testReplaceOnceFound() {
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.with:\"hello\" replace_first: \"l\" with:\"yo\"").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("heyolo", xValue.value);
    }
	
	@Test
    public void testReplaceOnceNotFound() {
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.with:\"hello\" replace_first: \"nope\" with:\"yo\"").get(0);

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
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.with:\"hello\" right_string_of_length:3").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("llo", xValue.getValue());
    }
	
	@Test
	public void testRightTooLarge(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.with:\"hello\" right_string_of_length:7").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("hello", xValue.getValue());
    }
	
	@Test
	public void testRightPadSimple(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.with:\"hello\" right_pad_with_length:8").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("hello   ", xValue.getValue());
    }
	
	@Test
	public void testSplitSimple(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.with:\"hello world 1\" split_with:\" \"").get(0);

		Array xValue = (Array)frame.getVariableNamed("x");
		StringValue firstValue = (StringValue)xValue.get(0);
		StringValue secondValue = (StringValue)xValue.get(1);
		StringValue thirdValue = (StringValue)xValue.get(2);
		Assert.assertEquals("hello", firstValue.getValue());
		Assert.assertEquals("world", secondValue.getValue());
		Assert.assertEquals("1", thirdValue.getValue());
	}
	
	@Test
	public void testSplitRepeat(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.with:\"hello  world 1\" split_with:\" \"").get(0);

		Array xValue = (Array)frame.getVariableNamed("x");
		StringValue firstValue = (StringValue)xValue.get(0);
		StringValue secondValue = (StringValue)xValue.get(1);
		StringValue thirdValue = (StringValue)xValue.get(2);
		Assert.assertEquals("hello", firstValue.getValue());
		Assert.assertEquals("world", secondValue.getValue());
		Assert.assertEquals("1", thirdValue.getValue());
	}
	
	@Test
	public void testSplitMultiple(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.with:\"xhellopworldx1p\" split_with:\"xp\"").get(0);

		Array xValue = (Array)frame.getVariableNamed("x");
		StringValue firstValue = (StringValue)xValue.get(0);
		StringValue secondValue = (StringValue)xValue.get(1);
		StringValue thirdValue = (StringValue)xValue.get(2);
		Assert.assertEquals("hello", firstValue.getValue());
		Assert.assertEquals("world", secondValue.getValue());
		Assert.assertEquals("1", thirdValue.getValue());
	}
	
	@Test
	public void testStartsWithTrue(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.does: \"hello\" start_with:\"hel\"").get(0);

		TrueValue xValue = (TrueValue)frame.getVariableNamed("x");
		Assert.assertEquals(true, xValue.getValue());
    }
	
	@Test
	public void testStartsWithFalse(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.does: \"hello\" start_with:\"yo\"").get(0);

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
	
	@Test
	public void testSubstringSimple(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.with:\"hello\" substring_from_index:0 to_index:2").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("he", xValue.value);
    }
	
	@Test
	public void testSubstringLargeFirst(){
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.with:\"hello\" substring_from_index:2 to_index:0").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("", xValue.value);
    }
	
	@Test
    public void testUppercaseSimple() {
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.upper_case: \"hello\"").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("HELLO", xValue.value);
    }
	
	@Test
    public void testUppercaseAlreadyUp() {
		String source = Helper.readResource("/integrations/StructureTest/simple.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", "x = string.upper_case: \"HELLO\"").get(0);

		StringValue xValue = (StringValue)frame.getVariableNamed("x");
		Assert.assertEquals("HELLO", xValue.value);
    }
}
