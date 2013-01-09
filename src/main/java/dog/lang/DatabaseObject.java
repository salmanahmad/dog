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

import com.mongodb.MongoClient;
import com.mongodb.WriteConcern;
import com.mongodb.DB;
import com.mongodb.DBCollection;
import com.mongodb.BasicDBObject;
import org.bson.types.ObjectId;

public abstract class DatabaseObject implements Persistable {
	Runtime runtime;

	public abstract ObjectId getId();
	public abstract String collectionName();

	public void setRuntime(Runtime runtime) {
		this.runtime = runtime;
	}

	public Runtime getRuntime() {
		return runtime;
	}

	DBCollection getCollection() {
		DB database = this.runtime.getDatabase();
		return database.getCollection(this.collectionName());
	}

	public void remove() {
		if(runtime == null) {
			throw new RuntimeException("Cannot save a DatabaseObject without an associated Runtime");
		}

		BasicDBObject query = new BasicDBObject();
		query.put("_id", this.getId());

		getCollection().remove(query);
	}

	public void save() {
		if(runtime == null) {
			throw new RuntimeException("Cannot save a DatabaseObject without an associated Runtime");
		}

		getCollection().save(this.toMongo());
	}
}
