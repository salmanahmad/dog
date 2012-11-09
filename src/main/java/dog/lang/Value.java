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

import org.json.JSONObject;
import com.mongodb.DBObject;
import org.bson.types.ObjectId;

public class Value {

    public ObjectId id;

    public Value() {
        this.id = new ObjectId();
    }

    public Object getValue() { return null; }
    
    // Note: Binary operations are performed with double dispatch. This means that in 
    // dispatchPlus(NumberValue v) for a + b, 'this' is 'b' and 'v' is 'a'. The order is
    // reversed than what you might expect it to be. 'this' is the second argument.
    public Value plus(Value v) { return v.dispatchPlus(this); }
    public Value minus(Value v) { return v.dispatchMinus(this); }
    public Value multiply(Value v) { return v.dispatchMultiply(this); }
    public Value divide(Value v) { return v.dispatchDivide(this); }
    public Value modulo(Value v) { return v.dispatchModulo(this); }
    public Value raisedTo(Value v) { return v.dispatchRaisedTo(this); }
    public Value equalTo(Value v) { return v.dispatchEqualTo(this); }
    public Value notEqualTo(Value v) { return v.dispatchEqualTo(this); }
    public Value lessThan(Value v) { return v.dispatchLessThan(this); }
    public Value greaterThan(Value v) { return v.dispatchGreaterThan(this); }
    public Value lessThanEqualTo(Value v) { return v.dispatchLessThanEqualTo(this); }
    public Value greaterThanEqualTo(Value v) { return v.dispatchGreaterThanEqualTo(this); }

    public Value dispatchPlus(Value v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchPlus(NullValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchPlus(TrueValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchPlus(FalseValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchPlus(NumberValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchPlus(StringValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchPlus(StructureValue v) { throw new RuntimeException("Unsupported binary operation."); }

    public Value dispatchMinus(Value v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchMinus(NullValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchMinus(TrueValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchMinus(FalseValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchMinus(NumberValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchMinus(StringValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchMinus(StructureValue v) { throw new RuntimeException("Unsupported binary operation."); }

    public Value dispatchMultiply(Value v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchMultiply(NullValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchMultiply(TrueValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchMultiply(FalseValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchMultiply(NumberValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchMultiply(StringValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchMultiply(StructureValue v) { throw new RuntimeException("Unsupported binary operation."); }

    public Value dispatchDivide(Value v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchDivide(NullValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchDivide(TrueValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchDivide(FalseValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchDivide(NumberValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchDivide(StringValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchDivide(StructureValue v) { throw new RuntimeException("Unsupported binary operation."); }

    public Value dispatchModulo(Value v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchModulo(NullValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchModulo(TrueValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchModulo(FalseValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchModulo(NumberValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchModulo(StringValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchModulo(StructureValue v) { throw new RuntimeException("Unsupported binary operation."); }

    public Value dispatchRaisedTo(Value v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchRaisedTo(NullValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchRaisedTo(TrueValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchRaisedTo(FalseValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchRaisedTo(NumberValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchRaisedTo(StringValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchRaisedTo(StructureValue v) { throw new RuntimeException("Unsupported binary operation."); }

    public Value dispatchEqualTo(Value v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchEqualTo(NullValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchEqualTo(TrueValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchEqualTo(FalseValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchEqualTo(NumberValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchEqualTo(StringValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchEqualTo(StructureValue v) { throw new RuntimeException("Unsupported binary operation."); }

    public Value dispatchNotEqualTo(Value v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchNotEqualTo(NullValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchNotEqualTo(TrueValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchNotEqualTo(FalseValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchNotEqualTo(NumberValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchNotEqualTo(StringValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchNotEqualTo(StructureValue v) { throw new RuntimeException("Unsupported binary operation."); }

    public Value dispatchLessThan(Value v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchLessThan(NullValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchLessThan(TrueValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchLessThan(FalseValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchLessThan(NumberValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchLessThan(StringValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchLessThan(StructureValue v) { throw new RuntimeException("Unsupported binary operation."); }

    public Value dispatchGreaterThan(Value v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchGreaterThan(NullValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchGreaterThan(TrueValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchGreaterThan(FalseValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchGreaterThan(NumberValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchGreaterThan(StringValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchGreaterThan(StructureValue v) { throw new RuntimeException("Unsupported binary operation."); }

    public Value dispatchLessThanEqualTo(Value v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchLessThanEqualTo(NullValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchLessThanEqualTo(TrueValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchLessThanEqualTo(FalseValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchLessThanEqualTo(NumberValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchLessThanEqualTo(StringValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchLessThanEqualTo(StructureValue v) { throw new RuntimeException("Unsupported binary operation."); }

    public Value dispatchGreaterThanEqualTo(Value v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchGreaterThanEqualTo(NullValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchGreaterThanEqualTo(TrueValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchGreaterThanEqualTo(FalseValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchGreaterThanEqualTo(NumberValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchGreaterThanEqualTo(StringValue v) { throw new RuntimeException("Unsupported binary operation."); }
    public Value dispatchGreaterThanEqualTo(StructureValue v) { throw new RuntimeException("Unsupported binary operation."); }

    public boolean isNull() { return false; }
    public boolean isBoolean() { return false; }
    public boolean isNumber() { return false; }
    public boolean isString() { return false; }
    public boolean isStructure() { return false; }

    public Value logicalInverse() { 
        return new FalseValue(); 
    }
    
    public Value logicalEquivalent() { 
        return new TrueValue(); 
    }

    public boolean booleanInverse() { 
        return false; 
    }
    
    public boolean booleanEquivalent() { 
        return true; 
    }

    public Value logicalAnd(Value v) { 
        if(v.booleanEquivalent() && this.booleanEquivalent()) {
            return new TrueValue();
        } else {
            return new FalseValue();
        }
    }
    public Value logicalOr(Value v) { 
        if(v.booleanEquivalent() || this.booleanEquivalent()) {
            return new TrueValue();
        } else {
            return new FalseValue();
        }
    }

    public Value identicalTo(Value v) { 
        if(this.id.equals(v.id)) {
            return new TrueValue();
        } else {
            return new FalseValue();
        }
    }
    
    public Value notIdenticalTo(Value v) { 
        if(!this.id.equals(v.id)) {
            return new TrueValue();
        } else {
            return new FalseValue();
        }
    }

    public JSONObject toJSON() {
        throw new RuntimeException("Unsupported binary operation.");
    }

    public DBObject toMongo() {
        throw new RuntimeException("Unsupported binary operation.");
    }
}

