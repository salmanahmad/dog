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

import java.util.HashMap;
import java.util.ArrayList;
import java.util.Iterator;

import com.mongodb.DBObject;
import com.mongodb.BasicDBObject;
import org.json.JSONObject;
import org.json.JSONException;

public class StructureValue extends Value {

	public HashMap<Object, Value> value = new HashMap<Object, Value>();

    public StructureValue() {
        super();
    }

	public StructureValue(HashMap<Object, Value> v) {
        super();
        value = v;
    }
    
    public Object getValue() {
        return value;
    }

    public String toString() {
        HashMap<Object, String> map = new HashMap<Object, String>();
        String type = "";

        for(Object key : value.keySet()) {
            Object v = value.get(key);
            map.put(key, v.toString());
        }

        if(!(this.getClass().equals(StructureValue.class) || this.getClass().equals(Type.class))) {
            type = Resolver.decodeSymbol(Resolver.convertJavaClassNameToJVMClassName(this.getClass().getName()));
        }

        return type + " " + map.toString();
    }

	public Value get(Object key) {
        Value v = this.value.get(key);
        
        if(v == null) {
            return new NullValue();
        } else {
            return v;
        }
    }

    public void put(Object key, Value value) {
        if((key instanceof Number) || (key instanceof String)) {
			this.value.put(key, value);
		}
    }

    public boolean isStructure() {
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
        // TODO: Should two structures be considered equal if they have the same
        // keys but are of different types? Right now, they are considered to be
        // equal but almost certainly will not be considered to be identical.

        if(!v.value.keySet().equals(this.value.keySet())) {
            return new FalseValue();
        }

        for(Object key : this.value.keySet()) {
            Value vValue = v.value.get(key);
            Value thisValue = this.value.get(key);

            if(vValue.equalTo(thisValue) instanceof FalseValue) {
                return new FalseValue();
            }
        }

        return new TrueValue();
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
        return new TrueValue();
    }
    
    public Value dispatchNotEqualTo(StructureValue v) {
        if(this.dispatchEqualTo(v) instanceof TrueValue) {
            return new TrueValue();
        } else {
            return new FalseValue();
        }
    }

    public Object toJSON() {
        try {
            JSONObject object = new JSONObject();

            for(Object k : value.keySet()) {
                Value v = value.get(k);
                object.put(k.toString(), v.toJSON());
            }

            return object;
        } catch(JSONException e) {
            return null;
        }
    }

    public DBObject toMongo() {
        DBObject object = super.toMongo();
        ArrayList value = new ArrayList();
        String type = "dog.structure";

        for(Object k : this.value.keySet()) {
            Value v = this.value.get(k);
            DBObject o = new BasicDBObject();

            o.put("key", k);
            o.put("value", v.toMongo());

            value.add(o);
        }

        if(!(this.getClass().equals(StructureValue.class) || this.getClass().equals(Type.class))) {
            type = Resolver.decodeSymbol(Resolver.convertJavaClassNameToJVMClassName(this.getClass().getName()));
        }

        object.put("value", value);
        object.put("type", type);

        return object;
    }

    public void fromJSON(JSONObject json, Resolver resolver) {
        Iterator iter = json.keys();
        while(iter.hasNext()) {
            String key = (String)iter.next();
            try {
                Object value = json.get(key);

                if(value == null) {
                    this.put(key, new NullValue());
                } else if(value instanceof Number) {
                    this.put(key, new NumberValue(((Number)value).doubleValue()));
                } else if(value instanceof String) {
                    this.put(key, new StringValue((String)value));
                } else if(value instanceof Boolean && (Boolean)value == true) {
                    this.put(key, new TrueValue());
                } else if(value instanceof Boolean && (Boolean)value == false) {
                    this.put(key, new FalseValue());
                } else if(value instanceof JSONObject) {
                    StructureValue structureValue = new StructureValue();
                    structureValue.fromJSON((JSONObject)value, resolver);
                    this.put(key, structureValue);
                }
            } catch (JSONException exception) {
                
            }
        }
    }

    public void fromMongo(DBObject bson, Resolver resolver) {
        super.fromMongo(bson, resolver);

        ArrayList values = (ArrayList)bson.get("value");

        for(Object item : values) {
            DBObject hash = (DBObject)item;
            DBObject mongoValue = (DBObject)hash.get("value");
            
            Value dogValue = null;
            String type = (String)mongoValue.get("type");

            if(type == "dog.null") {
                dogValue = new NullValue();
            } else if(type == "dog.boolean") {
                if((Boolean)mongoValue.get("value")) {
                    dogValue = new TrueValue();
                } else {
                    dogValue = new FalseValue();
                }
            } else if(type == "dog.number") {
                dogValue = new NumberValue();
            } else if(type == "dog.string") {
                dogValue = new StringValue();
            } else if(type == "dog.structure") {
                dogValue = new StructureValue();
            } else {
                dogValue = (Value)resolver.resolveSymbol(type);
            }

            dogValue.fromMongo(mongoValue, resolver);

            value.put(hash.get("key"), dogValue);
        }
    }
}

