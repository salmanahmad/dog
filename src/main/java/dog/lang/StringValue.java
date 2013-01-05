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

public class StringValue extends Value {
    
    public String value;
    
    public StringValue() {

    }

    public StringValue(String v) {
        super();
        value = v;
    }
    
    public Object getValue() {
        return value;
    }
    
    public String toString() {
        return "\"" + org.apache.commons.lang3.StringEscapeUtils.escapeJava(this.value) + "\"";
    }

    public Value plus(Value v) {
        return v.dispatchPlus(this);
    }
    
    public Value multiply(Value v) {
        return v.dispatchMultiply(this);
    }
    
    public Value equalTo(Value v) {
        return v.dispatchEqualTo(this);
    }
    
    public Value notEqualTo(Value v) {
        return v.dispatchEqualTo(this);
    }
    
    public Value lessThan(Value v) {
        return v.dispatchLessThan(this);
    }
    
    public Value greaterThan(Value v) {
        return v.dispatchGreaterThan(this);
    }
    
    public Value lessThanEqualTo(Value v) {
        return v.dispatchLessThanEqualTo(this);
    }
    
    public Value greaterThanEqualTo(Value v) {
        return v.dispatchGreaterThanEqualTo(this);
    }
    
    public Value dispatchPlus(NumberValue v) {
        return new StringValue(v.value + this.value);
    }
    
    public Value dispatchPlus(StringValue v) {
        return new StringValue(v.value + this.value);
    }

    public Value dispatchMultiply(NumberValue v) {
        String output = "";
        
        for (int i = 0; i < v.value; i++) {
            output += this.value;
        }
        
        return new StringValue(output);
    }

    public Value dispatchEqualTo(Value v) {
        return new FalseValue();
    }
    
    public Value dispatchEqualTo(NullValue v) {
        return new FalseValue();
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
        if(v.value.equals(this.value)) {
            return new TrueValue();
        } else {
            return new FalseValue();
        }
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
        return new TrueValue();
    }
    
    public Value dispatchNotEqualTo(FalseValue v) {
        return new TrueValue();
    }
    
    public Value dispatchNotEqualTo(NumberValue v) {
        return new TrueValue();
    }
    
    public Value dispatchNotEqualTo(StringValue v) {
        if(!v.value.equals(this.value)) {
            return new TrueValue();
        } else {
            return new FalseValue();
        }
    }
    
    public Value dispatchNotEqualTo(StructureValue v) {
        return new TrueValue();
    }

    public Value dispatchLessThan(StringValue v) {
        if(v.value.compareTo(this.value) < 0) {
            return new TrueValue();
        } else {
            return new FalseValue();
        }
    }
    
    public Value dispatchGreaterThan(StringValue v) {
        if(v.value.compareTo(this.value) > 0) {
            return new TrueValue();
        } else {
            return new FalseValue();
        }
    }
    
    public Value dispatchLessThanEqualTo(StringValue v) {
        if(v.value.compareTo(this.value) < 0 || v.value.equals(this.value)) {
            return new TrueValue();
        } else {
            return new FalseValue();
        }
    }
    
    public Value dispatchGreaterThanEqualTo(StringValue v) {
        if(v.value.compareTo(this.value) > 0 || v.value.equals(this.value)) {
            return new TrueValue();
        } else {
            return new FalseValue();
        }
    }
    
    public boolean isString() {
        return true;
    }

    public Object toJSON() {
        return this.value;
    }

    public DBObject toMongo() {
        DBObject object = super.toMongo();

        object.put("value", this.getValue());
        object.put("type", "dog.string");

        return object;
    }

    public void fromMongo(DBObject bson, Resolver resolver) {
        super.fromMongo(bson, resolver);

        this.value = (String)bson.get("value");
    }
}

