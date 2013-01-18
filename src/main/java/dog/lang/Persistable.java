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

import org.json.JSONObject;
import com.mongodb.DBObject;

public interface Persistable {
	public Map toMap();
	public Object toJSON();
	public DBObject toMongo();

	public void fromMap(Map map, Resolver resolver);
	public void fromJSON(JSONObject json, Resolver resolver);
	public void fromMongo(DBObject bson, Resolver resolver);
}

