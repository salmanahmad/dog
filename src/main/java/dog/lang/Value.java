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

import java.util.Map;

import com.mongodb.DBObject;
import com.mongodb.BasicDBObject;
import org.bson.types.ObjectId;
import org.json.JSONObject;

public class Value implements Persistable {

    private ObjectId id;

    public ObjectId futureId = null;
    public boolean pending = false;
    public boolean channelMode = false;
    public int channelSize = 0;

    public ObjectId getId() {
        if (this.id == null) {
            this.id = new ObjectId();
        }

        return this.id;
    }

    public void setId(ObjectId id) {
        this.id = id;
    }

    public Object getValue(int register) {
        checkForPendingValue(this, register);
        return getValue();
    }

    public Object getValue() { return null; }
    
    public void checkForPendingValue(Value value, int register) {
        if(value.pending) {
            throw new WaitingException(value.getId(), register);
        }
    }

    public void checkForPendingValues(Value value1, Value value2, int inputRegister1, int inputRegister2) {
        checkForPendingValue(value1, inputRegister1);
        checkForPendingValue(value2, inputRegister2);
    }

    public Value plus(Value v, int inputRegister1, int inputRegister2) { 
        checkForPendingValues(this, v, inputRegister1, inputRegister2);
        return plus(v);
    }
    
    public Value minus(Value v, int inputRegister1, int inputRegister2) { 
        checkForPendingValues(this, v, inputRegister1, inputRegister2);
        return minus(v);
    }
    
    public Value multiply(Value v, int inputRegister1, int inputRegister2) { 
        checkForPendingValues(this, v, inputRegister1, inputRegister2);
        return multiply(v);
    }
    
    public Value divide(Value v, int inputRegister1, int inputRegister2) { 
        checkForPendingValues(this, v, inputRegister1, inputRegister2);
        return divide(v);
    }
    
    public Value modulo(Value v, int inputRegister1, int inputRegister2) { 
        checkForPendingValues(this, v, inputRegister1, inputRegister2);
        return modulo(v);
    }
    
    public Value raisedTo(Value v, int inputRegister1, int inputRegister2) { 
        checkForPendingValues(this, v, inputRegister1, inputRegister2);
        return raisedTo(v);
    }
    
    public Value equalTo(Value v, int inputRegister1, int inputRegister2) { 
        checkForPendingValues(this, v, inputRegister1, inputRegister2);
        return equalTo(v);
    }
    
    public Value notEqualTo(Value v, int inputRegister1, int inputRegister2) { 
        checkForPendingValues(this, v, inputRegister1, inputRegister2);
        return notEqualTo(v);
    }
    
    public Value lessThan(Value v, int inputRegister1, int inputRegister2) { 
        checkForPendingValues(this, v, inputRegister1, inputRegister2);
        return lessThan(v);
    }
    
    public Value greaterThan(Value v, int inputRegister1, int inputRegister2) { 
        checkForPendingValues(this, v, inputRegister1, inputRegister2);
        return greaterThan(v);
    }
    
    public Value lessThanEqualTo(Value v, int inputRegister1, int inputRegister2) { 
        checkForPendingValues(this, v, inputRegister1, inputRegister2);
        return lessThanEqualTo(v);
    }
    
    public Value greaterThanEqualTo(Value v, int inputRegister1, int inputRegister2) { 
        checkForPendingValues(this, v, inputRegister1, inputRegister2);
        return greaterThanEqualTo(v);
    }

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

    public Value logicalInverse(int register) { 
        checkForPendingValue(this, register);
        return logicalInverse();
    }
    
    public Value logicalEquivalent(int register) { 
        checkForPendingValue(this, register);
        return logicalEquivalent();   
    }

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

    public Value logicalAnd(Value v, int inputRegister1, int inputRegister2) {
        checkForPendingValues(this, v, inputRegister1, inputRegister2);
        return logicalAnd(v);
    } 

    public Value logicalOr(Value v, int inputRegister1, int inputRegister2) {
        checkForPendingValues(this, v, inputRegister1, inputRegister2);
        return logicalOr(v);
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

    public Value identicalTo(Value v, int inputRegister1, int inputRegister2) {
        checkForPendingValues(this, v, inputRegister1, inputRegister2);
        return identicalTo(v);
    }

    public Value notIdenticalTo(Value v, int inputRegister1, int inputRegister2) {
        checkForPendingValues(this, v, inputRegister1, inputRegister2);
        return notIdenticalTo(v);
    }

    public Value identicalTo(Value v) {
        if(this.getId().equals(v.getId())) {
            return new TrueValue();
        } else {
            return new FalseValue();
        }
    }
    
    public Value notIdenticalTo(Value v) {
        if(!this.getId().equals(v.getId())) {
            return new TrueValue();
        } else {
            return new FalseValue();
        }
    }

    public Value get(Object key, int register) {
        checkForPendingValue(this, register);
        return get(key);
    }

    public Value get(Object key) {
        throw new RuntimeException("Cannot access key for non-structure type.");
    }

    public void put(Object key, Value value, int register) {
        checkForPendingValue(this, register);
        put(key, value);
    }    

    public void put(Object key, Value value) {
        throw new RuntimeException("Cannot assign key for non-structure type.");
    }
    
    public Map toMap() {
        return toMongo().toMap();
    }

    public Object toJSON() {
        throw new RuntimeException("toJSON must be implemented by a subclass.");
    }

    public DBObject toMongo() {
        DBObject object = new BasicDBObject();

        object.put("_id", this.getId());
        object.put("future_id", this.futureId);
        object.put("pending", this.pending);
        object.put("channel_mode", this.channelMode);
        object.put("channel_size", this.channelSize);

        return object;
    }

    public void fromMap(Map map, Resolver resolver) {
        this.fromMongo(new BasicDBObject(map), resolver);
    }

    public void fromJSON(JSONObject json, Resolver resolver) {
        throw new RuntimeException("fromJSON must be implemented by a subclass.");
    }

    public void fromMongo(DBObject bson, Resolver resolver) {
        this.setId((ObjectId)bson.get("_id"));

        this.futureId = (ObjectId)bson.get("future_id");
        this.pending = (Boolean)bson.get("pending");
        this.channelMode = (Boolean)bson.get("channel_mode");
        this.channelSize = (Integer)bson.get("channel_size");
    }

    public static Value createFromMap(Map map, Resolver resolver) {
        return Value.createFromMongo(new BasicDBObject(map), resolver);
    }

    public static Value createFromJSON(JSONObject json, Resolver resolver) {
        Value value = new StructureValue();
        value.fromJSON(json, resolver);
        
        return value;
    }

    public static Value createFromMongo(DBObject bson, Resolver resolver) {
        String type = (String)bson.get("type");
        Value value = null;

        if(type.equals("dog.null")) {
            value = new NullValue();
        } else if(type.equals("dog.boolean")) {
            if((Boolean)bson.get("value")) {
                value = new TrueValue();
            } else {
                value = new FalseValue();
            }
        } else if(type.equals("dog.number")) {
            value = new NumberValue();
        } else if(type.equals("dog.string")) {
            value = new StringValue();
        } else if(type.equals("dog.structure")) {
            value = new StructureValue();
        } else {
            value = (Value)resolver.resolveSymbol(type);
        }

        value.fromMongo(bson, resolver);
        return value;
    }
}

