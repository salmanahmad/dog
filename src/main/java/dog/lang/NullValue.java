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
import org.json.JSONObject;

public class NullValue extends Value {

    public Object getValue() {
        return null;
    }

    public String toString() {
        return "null";
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
        return new TrueValue();
    }
    
    public Value dispatchEqualTo(TrueValue v) {
        return new FalseValue();
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
        return new FalseValue();
    }
    
    public Value dispatchNotEqualTo(TrueValue v) {
        return new TrueValue();
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

    public Value logicalInverse() {
        return new TrueValue();
    }
    public Value logicalEquivalent() {
        return new FalseValue();
    }

    public boolean booleanInverse() {
        return true;
    }
    public boolean booleanEquivalent() {
        return false;
    }

    public boolean isNull() {
        return true;
    }

    public Object toJSON() {
        return JSONObject.NULL;    
    }

    public DBObject toMongo() {
        DBObject object = super.toMongo();

        object.put("value", null);
        object.put("type", "dog.null");

        return object;
    }

    public void fromMongo(DBObject bson, Resolver resolver) {
        super.fromMongo(bson, resolver);
    }
}

