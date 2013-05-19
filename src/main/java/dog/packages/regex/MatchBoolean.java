package dog.packages.regex;

import dog.lang.Value;
import dog.lang.StringValue;
import dog.lang.NullValue;
import dog.lang.TrueValue;
import dog.lang.FalseValue;
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
 * Module that provides regular expression support.
 * @module Regex
 **/
 
/**
 * Checks if matches of a pattern exist a string.
 * Returns a TrueValue or FalseValue when executed normally, or NullValue 
 * when there is an exception or invalid arguments.
 **/
 
/**
 * @method does_pattern:match:
 * @param {StringValue} pattern The regex pattern
 * @param {StringValue} subject The string to perform matching on
 * @return {StructureValue} returnValue 
 **/  
@Symbol("regex.does_pattern:match:")
public class MatchBoolean extends Function {
	public int getVariableCount() {
		return 2;
	}
	
	public int getRegisterCount() {
		return 1;
	}
	
	public Signal resume(StackFrame frame) {
		Value pattern = frame.variables[0];
		Value subject = frame.variables[1];
		Value returnValue;
		
		if (pattern instanceof StringValue && subject instanceof StringValue) {
			StringValue pstr = (StringValue)pattern;
			StringValue sstr = (StringValue)subject;
			try{
				Pattern p = Pattern.compile(pstr.value);
				Matcher m = p.matcher(sstr.value);
				boolean b = m.find();
				if (b){
					returnValue = new TrueValue();
				}else{
					returnValue = new FalseValue();
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
		
			