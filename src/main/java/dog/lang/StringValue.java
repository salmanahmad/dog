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

package dog.lang;

public class StringValue extends Value {
    
    public String value;
    
    public StringValue(String v) {
        super();
        value = v;
    }
    
    public Object getValue() {
        return value;
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
        throw new RuntimeException("Unsupported binary operation.");
    }

    public Value dispatchMultiply(NumberValue v) {
        throw new RuntimeException("Unsupported binary operation.");
    }

    public Value dispatchEqualTo(Value v) {
        throw new RuntimeException("Unsupported binary operation.");
    }
    
    public Value dispatchEqualTo(NullValue v) {
        throw new RuntimeException("Unsupported binary operation.");
    }
    
    public Value dispatchEqualTo(TrueValue v) {
        throw new RuntimeException("Unsupported binary operation.");
    }
    
    public Value dispatchEqualTo(FalseValue v) {
        throw new RuntimeException("Unsupported binary operation.");
    }
    
    public Value dispatchEqualTo(NumberValue v) {
        throw new RuntimeException("Unsupported binary operation.");
    }
    
    public Value dispatchEqualTo(StringValue v) {
        throw new RuntimeException("Unsupported binary operation.");
    }
    
    public Value dispatchEqualTo(StructureValue v) {
        throw new RuntimeException("Unsupported binary operation.");
    }

    public Value dispatchNotEqualTo(Value v) {
        throw new RuntimeException("Unsupported binary operation.");
    }
    
    public Value dispatchNotEqualTo(NullValue v) {
        throw new RuntimeException("Unsupported binary operation.");
    }
    
    public Value dispatchNotEqualTo(TrueValue v) {
        throw new RuntimeException("Unsupported binary operation.");
    }
    
    public Value dispatchNotEqualTo(FalseValue v) {
        throw new RuntimeException("Unsupported binary operation.");
    }
    
    public Value dispatchNotEqualTo(NumberValue v) {
        throw new RuntimeException("Unsupported binary operation.");
    }
    
    public Value dispatchNotEqualTo(StringValue v) {
        throw new RuntimeException("Unsupported binary operation.");
    }
    
    public Value dispatchNotEqualTo(StructureValue v) {
        throw new RuntimeException("Unsupported binary operation.");
    }

    public Value dispatchLessThan(StringValue v) {
        throw new RuntimeException("Unsupported binary operation.");
    }
    
    public Value dispatchGreaterThan(StringValue v) {
        throw new RuntimeException("Unsupported binary operation.");
    }
    
    public Value dispatchLessThanEqualTo(StringValue v) {
        throw new RuntimeException("Unsupported binary operation.");
    }
    
    public Value dispatchGreaterThanEqualTo(StringValue v) {
        throw new RuntimeException("Unsupported binary operation.");
    }
    
    
    
    public boolean isString() {
        return true;
    }
}

