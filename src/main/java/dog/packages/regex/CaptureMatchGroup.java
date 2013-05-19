package dog.packages.regex;

import dog.lang.Value;
import dog.lang.StringValue;
import dog.lang.NullValue;
import dog.lang.StructureValue;
import dog.lang.Function;
import dog.lang.Signal;
import dog.lang.Resolver;
import dog.lang.StackFrame;
import dog.lang.annotation.Symbol;

import java.util.Arrays;
import java.util.ArrayList;
import java.util.regex.Pattern;
import java.util.regex.Matcher;

import java.lang.String;
/**
 * @language java
 **/
/**
 * @module Regex
 **/
 
/**
 * Finds the the captured groups in matches of a pattern in a string.
 * Returns a StructureValue when executed normally, or NullValue 
 * when there is an exception or invalid arguments.
 * The StructureValue has keys of incrementing number strings and values 
 * of starting indexes of the matched substring in NumberValue.
 * @class CaptureMatchGroup
 **/
 
 /**
 * @method with:capture_with_pattern:
 * @param {StringValue} subject The string to perform matching on
 * @param {StringValue} pattern The regex pattern
 * @return {StructureValue} returnValue 
 **/
@Symbol("regex.with:capture_with_pattern:")
public class CaptureMatchGroup extends Function {
	public int getVariableCount() {
		return 2;
	}
	
	public int getRegisterCount() {
		return 2;
	}
	
	public Signal resume(StackFrame frame) {
		Value pattern = frame.variables[1];
		Value subject = frame.variables[0];
		Value returnValue;
		
		if (pattern instanceof StringValue && subject instanceof StringValue) {
			StringValue pstr = (StringValue)pattern;
			StringValue sstr = (StringValue)subject;
			try{
				Pattern p = Pattern.compile(pstr.value);
				Matcher m = p.matcher(sstr.value);
				returnValue = new StructureValue();
				int gCount = m.groupCount();
				int fCount = 0;
				while (m.find()){
					StructureValue oneMatch = new StructureValue();
					for (int i=0; i<=gCount; i++){
						if (m.group(i) !=null){
							StringValue sv = new StringValue(m.group(i));
							oneMatch.put(Integer.toString(i),sv);
						}else{
							oneMatch.put(Integer.toString(i), new NullValue());
						}
					}
					returnValue.put(Integer.toString(fCount), oneMatch);
					fCount++;
				}
			}catch (Exception e){
				returnValue = new NullValue();
			}
		}else{
			returnValue = new NullValue();
		}
			
		frame.registers[0] = returnValue;
		frame.returnRegister = 0;
		
		return new Signal(Signal.Type.RETURN);
		
	}
}
		
			