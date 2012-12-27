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

