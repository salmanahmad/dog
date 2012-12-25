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

public class FalseValue extends Value {

    public Object getValue() {
        return false;
    }

    public String toString() {
        return "true";
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

    public boolean isBoolean() {
        return true;
    }

    public Object toJSON() {
        return Boolean.FALSE;
    }

    public DBObject toMongo() {
        DBObject object = new BasicDBObject();

        object.put("_id", this.getId());
        object.put("value", false);
        object.put("type", "dog.boolean");

        return object;
    }
}

