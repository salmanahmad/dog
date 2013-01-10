
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

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.json.JSONObject;
import com.mongodb.DBObject;
import com.mongodb.BasicDBObject;
import com.mongodb.MongoClient;
import com.mongodb.DB;
import com.mongodb.DBCollection;
import org.bson.types.ObjectId;

public class Future extends DatabaseObject {
	
	ObjectId valueId = null;
	Value value = null;
	
	ArrayList<Value> queue = new ArrayList<Value>();
	int queueSize = 0;

	ArrayList<Object> blockingStackFrames = new ArrayList<Object>();
	ArrayList<Object> broadcastStackFrames = new ArrayList<Object>();
	ArrayList<String> handlers = new ArrayList<String>();

	public Future(Runtime runtime) {
		this.runtime = runtime;
	}

	public String collectionName() {
		return "futures";
	}

	public Map toMap() {
		return toMongo().toMap();
	}

	public JSONObject toJSON() {
		return null;
	}

	public DBObject toMongo() {
		BasicDBObject hash = new BasicDBObject();
		hash.put("_id", this.getId());
		
		hash.put("value_id", this.valueId);
		hash.put("value", this.value.toMongo());

		ArrayList<DBObject> queueList = new ArrayList<DBObject>();
		for(Value v : queue) {
			queueList.add(v.toMongo());
		}

		hash.put("queue", queueList);
		hash.put("queue_size", this.queueSize);

		ArrayList<ObjectId> list = null;

		list = new ArrayList<ObjectId>();
		for(Object frame : this.blockingStackFrames) {
			if(frame instanceof StackFrame) {
				StackFrame theFrame = (StackFrame)frame;

				theFrame.setRuntime(runtime);
				theFrame.save();
				list.add(theFrame.getId());
			} else if(frame instanceof ObjectId) {
				list.add((ObjectId)frame);
			}
		}

		hash.put("blocking_stack_frames", list);

		list = new ArrayList<ObjectId>();
		for(Object frame : this.broadcastStackFrames) {
			if(frame instanceof StackFrame) {
				StackFrame theFrame = (StackFrame)frame;

				theFrame.setRuntime(runtime);
				theFrame.save();
				list.add(theFrame.getId());
			} else if(frame instanceof ObjectId) {
				list.add((ObjectId)frame);
			}
		}

		hash.put("broadcast_stack_frames", list);
		hash.put("handlers", this.handlers);

		return hash;
	}

	public void fromMap(Map map, Resolver resolver) {
		this.fromMongo(new BasicDBObject(map), resolver);
	}

	public void fromJSON(JSONObject json, Resolver resolver) {
		
	}

	public void fromMongo(DBObject bson, Resolver resolver) {
		this.id = (ObjectId)bson.get("_id");

		this.valueId = (ObjectId)bson.get("value_id");
		this.value = Value.createFromMongo((DBObject)bson.get("value"), resolver);

		for(Object o : (List)bson.get("queue")) {
			this.queue.add(Value.createFromMongo((DBObject)o, resolver));
		}
		this.queueSize = (Integer)bson.get("queue_size");

		for(Object object : (List)bson.get("blocking_stack_frames")) {
			this.blockingStackFrames.add(object);
		}

		for(Object object : (List)bson.get("broadcast_stack_frames")) {
			this.blockingStackFrames.add(object);
		}

		for(Object object : (List)bson.get("handlers")) {
			this.handlers.add((String)object);
		}


	}


}
