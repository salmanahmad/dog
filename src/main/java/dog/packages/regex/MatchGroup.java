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
 * Finds matches of a pattern in a string.
 * Returns a StructureValue when executed normally, or NullValue 
 * when there is an exception or invalid arguments.
 * The StructureValue has keys of incrementing number strings and values 
 * of the matched substring in StringValue.
 * @class MatchGroup
 **/
 
 /**
 * @method with:match_with_pattern:
 * @param {StringValue} subject The string to perform matching on
 * @param {StringValue} pattern The regex pattern
 * @return {StructureValue} returnValue 
 **/
@Symbol("regex.with:match_with_pattern:")
public class MatchGroup extends Function {
	public int getVariableCount() {
		return 2;
	}
	
	public int getRegisterCount() {
		return 1;
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
				int rkey = 0;
				while (m.find()){
					StringValue sv = new StringValue(m.group());
					returnValue.put(Integer.toString(rkey), sv);
					rkey++;
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
		
			