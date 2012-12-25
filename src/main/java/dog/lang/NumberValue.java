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

public class NumberValue extends Value {

    public double value;
    
    public NumberValue(double v) {
        super();
        value = v;
    }
    
    public Object getValue() {
        return value;
    }
    
    public String toString() {
        return "" + value;
    }

    public Value plus(Value v) { 
        return v.dispatchPlus(this); 
    }
    
    public Value minus(Value v) { 
        return v.dispatchMinus(this); 
    }
    
    public Value multiply(Value v) { 
        return v.dispatchMultiply(this); 
    }
    
    public Value divide(Value v) { 
        return v.dispatchDivide(this); 
    }
    
    public Value modulo(Value v) {
        return v.dispatchModulo(this);
    }
    
    public Value raisedTo(Value v) {
        return v.dispatchRaisedTo(this);
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
        return new NumberValue(v.value + this.value);
    }
    
    public Value dispatchPlus(StringValue v) {
        return new StringValue(v.value + this.value);
    }

    public Value dispatchMinus(NumberValue v) {
        return new NumberValue(v.value - this.value);
    }

    public Value dispatchMultiply(NumberValue v) {
        return new NumberValue(v.value * this.value);
    }
    
    public Value dispatchMultiply(StringValue v) {
        String output = "";
        
        for (int i = 0; i < this.value; i++) {
            output += v.value;
        }
        
        return new StringValue(output);
    }

    public Value dispatchDivide(NumberValue v) {
        return new NumberValue(v.value / this.value);
    }

    public Value dispatchModulo(NumberValue v) {
        return new NumberValue(v.value % this.value);
    }

    public Value dispatchRaisedTo(NumberValue v) {
        return new NumberValue(Math.pow(v.value, this.value));
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
        if(v.value == this.value) {
            return new TrueValue();
        } else {
            return new FalseValue();
        }
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
        return new TrueValue();
    }
    
    public Value dispatchNotEqualTo(FalseValue v) {
        return new TrueValue();
    }
    
    public Value dispatchNotEqualTo(NumberValue v) {
        if(v.value != this.value) {
            return new TrueValue();
        } else {
            return new FalseValue();
        }
    }
    
    public Value dispatchNotEqualTo(StringValue v) {
        return new TrueValue();
    }
    
    public Value dispatchNotEqualTo(StructureValue v) {
        return new TrueValue();
    }

    public Value dispatchLessThan(NumberValue v) {
        if(v.value < this.value) {
            return new TrueValue();
        } else {
            return new FalseValue();
        }
    }

    public Value dispatchGreaterThan(NumberValue v) {
        if(v.value > this.value) {
            return new TrueValue();
        } else {
            return new FalseValue();
        }
    }

    public Value dispatchLessThanEqualTo(NumberValue v) {
        if(v.value <= this.value) {
            return new TrueValue();
        } else {
            return new FalseValue();
        }
    }

    public Value dispatchGreaterThanEqualTo(NumberValue v) {
        if(v.value >= this.value) {
            return new TrueValue();
        } else {
            return new FalseValue();
        }
    }
    
    public boolean isNumber() {
        return true;
    }

    public Object toJSON() {
        return this.value;
    }

    public DBObject toMongo() {
        DBObject object = new BasicDBObject();

        object.put("_id", this.getId());
        object.put("value", this.getValue());
        object.put("type", "dog.number");

        return object;
    }
}

