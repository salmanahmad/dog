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


import org.junit.*;
import java.util.*;

import dog.lang.*;

import com.mongodb.DBObject;
import com.mongodb.BasicDBObject;
import org.json.JSONObject;

public class PersistableTest {
    
    @Test
    public void testNumber() {
        Resolver resolver = new Resolver();
        NumberValue number = new NumberValue(6);
        DBObject mongoNumber = number.toMongo();
        Value newNumber = Value.createFromMongo(mongoNumber, resolver);

        Assert.assertTrue(newNumber instanceof NumberValue);
        Assert.assertEquals(newNumber.getId(), number.getId());
        Assert.assertEquals(newNumber.getValue(), number.getValue());
    }

    @Test
    public void testTrue() {
        Resolver resolver = new Resolver();
        TrueValue value = new TrueValue();
        DBObject mongo = value.toMongo();

        Value newValue = Value.createFromMongo(mongo, resolver);
        Assert.assertTrue(newValue instanceof TrueValue);
        Assert.assertEquals(newValue.getId(), value.getId());
    }

    @Test
    public void testFalse() {
        Resolver resolver = new Resolver();
        FalseValue value = new FalseValue();
        DBObject mongo = value.toMongo();

        Value newValue = Value.createFromMongo(mongo, resolver);
        Assert.assertTrue(newValue instanceof FalseValue);
        Assert.assertEquals(newValue.getId(), value.getId());
    }

    @Test
    public void testString() {
        Resolver resolver = new Resolver();
        StringValue value = new StringValue("This is a test");
        DBObject mongo = value.toMongo();
        Value newValue = Value.createFromMongo(mongo, resolver);

        Assert.assertTrue(newValue instanceof StringValue);
        Assert.assertEquals(newValue.getId(), value.getId());
        Assert.assertEquals(newValue.getValue(), value.getValue());
    }

    @Test
    public void testNull() {
        Resolver resolver = new Resolver();
        NullValue value = new NullValue();
        DBObject mongo = value.toMongo();

        Value newValue = Value.createFromMongo(mongo, resolver);
        Assert.assertTrue(newValue instanceof NullValue);
        Assert.assertEquals(newValue.getId(), value.getId());
    }

    @Test
    public void testStructure() {
        Resolver resolver = new Resolver();

        StructureValue value = new StructureValue();
        value.put(1, new TrueValue());
        value.put(2, new FalseValue());
        value.put(3, new NullValue());
        value.put("string", new StringValue("Hello, World"));
        value.put("number", new NumberValue(3.14));

        DBObject mongo = value.toMongo();
        Value newValue = Value.createFromMongo(mongo, resolver);
        Assert.assertTrue(newValue instanceof StructureValue);
        Assert.assertEquals(newValue.getId(), value.getId());
        Assert.assertEquals(((HashMap<Object, Value>)newValue.getValue()).size(), ((HashMap<Object, Value>)value.getValue()).size());
        Assert.assertTrue(newValue.equalTo(value) instanceof TrueValue);
    }

    @Test
    public void testArray() {
        
    }
}
