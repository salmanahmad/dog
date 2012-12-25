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
        DBObject object = new BasicDBObject();

        object.put("_id", this.getId());
        object.put("value", null);
        object.put("type", "dog.null");

        return object;
    }
}

