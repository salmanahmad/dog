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

import org.json.JSONObject;
import com.mongodb.DBObject;

public interface Persistable {
	public JSONObject toJSON();
	public DBObject toMongo();

	public void fromJSON(JSONObject json, Resolver resolver);
	public void fromMongo(DBObject bson, Resolver resolver);
}

