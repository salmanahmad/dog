/*
 *
 *  Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
 *  All rights reserved.
 *
 *  Permission is granted for use, copying, modification, distribution,
 *  and distribution of modified versions of this work as long as the
 *  above copyright notice is included.
 *
 */


import org.junit.*;
import java.util.*;

import dog.lang.NumberValue;
import dog.lang.StringValue;

public class NumberValueTest {
    
    @Test
    public void testPlus() {
        NumberValue v1;
        NumberValue v2;
        
        v1 = new NumberValue(5);
        v2 = new NumberValue(5);
        
        Assert.assertEquals(10.0, ((NumberValue)v1.plus(v2)).value, 0.0);
        
        v1 = new NumberValue(5);
        v2 = new NumberValue(10);
        
        Assert.assertEquals(15.0, ((NumberValue)v1.plus(v2)).value, 0.0);
    }
    
    @Test
    public void testMinus() {
        NumberValue v1;
        NumberValue v2;
        
        v1 = new NumberValue(5);
        v2 = new NumberValue(5);
        
        Assert.assertEquals(0.0, ((NumberValue)v1.minus(v2)).value, 0.0);
        
        v1 = new NumberValue(5);
        v2 = new NumberValue(10);
        
        Assert.assertEquals(-5.0, ((NumberValue)v1.minus(v2)).value, 0.0);
    }
    
    @Test
    public void testMulitply() {
        NumberValue v1;
        NumberValue v2;
        
        v1 = new NumberValue(5);
        v2 = new NumberValue(5);
        
        Assert.assertEquals(25.0, ((NumberValue)v1.multiply(v2)).value, 0.0);
        
        v1 = new NumberValue(-5);
        v2 = new NumberValue(10);
        
        Assert.assertEquals(-50.0, ((NumberValue)v1.multiply(v2)).value, 0.0);
    }
    
    @Test
    public void testDivide() {
        NumberValue v1;
        NumberValue v2;
        
        v1 = new NumberValue(5);
        v2 = new NumberValue(5);
        
        Assert.assertEquals(1.0, ((NumberValue)v1.divide(v2)).value, 0.0);
        
        v1 = new NumberValue(-5);
        v2 = new NumberValue(10);
        
        Assert.assertEquals(-0.5, ((NumberValue)v1.divide(v2)).value, 0.0);
    }
    
    @Test
    public void testLessThan() {
        NumberValue v1;
        NumberValue v2;
        
        v1 = new NumberValue(5);
        v2 = new NumberValue(10);
        
        Assert.assertTrue(v1.lessThan(v2) instanceof dog.lang.TrueValue);
    }
    
    @Test
    public void testGreaterThan() {
        NumberValue v1;
        NumberValue v2;
        
        v1 = new NumberValue(5);
        v2 = new NumberValue(10);
        
        Assert.assertTrue(v1.greaterThan(v2) instanceof dog.lang.FalseValue);
    }
    
    @Test
    public void testConcatentation() {
        NumberValue v1;
        StringValue v2;
        
        v1 = new NumberValue(5);
        v2 = new StringValue("foo");
        
        Assert.assertEquals("5.0foo", ((StringValue)v1.plus(v2)).value);
    }
}
