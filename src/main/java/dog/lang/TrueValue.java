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

package dog.lang;

import com.mongodb.DBObject;
import com.mongodb.BasicDBObject;

public class TrueValue extends Value {
    public Object getValue() {
        return true;
    }
    
    public String toString() {
        return "true";
    }

    public boolean isBoolean() {
        return true;
    }
    
    public Value equalTo(Value v) { 
        return v.dispatchEqualTo(this); 
    }
    
    public Value notEqualTo(Value v) { 
        return v.dispatchEqualTo(this); 
    }

    public Value dispatchEqualTo(Value v) {
        return new FalseValue();
    }
    
    public Value dispatchEqualTo(NullValue v) {
        return new FalseValue();
    }
    
    public Value dispatchEqualTo(TrueValue v) {
        return new TrueValue();
    }
    
    public Value dispatchEqualTo(FalseValue v) {
        return new FalseValue();
    }
    
    public Value dispatchEqualTo(NumberValue v) {
        return new FalseValue();
    }
    
    public Value dispatchEqualTo(StringValue v) {
        return new FalseValue();
    }
    
    public Value dispatchEqualTo(StructureValue v) {
        return new FalseValue();
    }

    public Value dispatchNotEqualTo(Value v) {
        return new TrueValue();
    }
    
    public Value dispatchNotEqualTo(NullValue v) {
        return new TrueValue();
    }
    
    public Value dispatchNotEqualTo(TrueValue v) {
        return new FalseValue();
    }
    
    public Value dispatchNotEqualTo(FalseValue v) {
        return new TrueValue();
    }
    
    public Value dispatchNotEqualTo(NumberValue v) {
        return new TrueValue();
    }
    
    public Value dispatchNotEqualTo(StringValue v) {
        return new TrueValue();
    }
    
    public Value dispatchNotEqualTo(StructureValue v) {
        return new TrueValue();
    }





    public Object toJSON() {
        return Boolean.TRUE;
    }

    public DBObject toMongo() {
        DBObject object = super.toMongo();

        object.put("value", true);
        object.put("type", "dog.boolean");

        return object;
    }

    public void fromMongo(DBObject bson, Resolver resolver) {
        super.fromMongo(bson, resolver);
    }
}

