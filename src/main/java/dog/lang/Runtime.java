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

import dog.lang.*;

import java.util.concurrent.LinkedBlockingQueue;
import java.util.LinkedHashMap;
import java.util.ArrayList;
import java.util.List;
import java.net.UnknownHostException;

import com.mongodb.MongoClient;
import com.mongodb.DB;
import com.mongodb.DBCursor;
import com.mongodb.DBObject;
import com.mongodb.BasicDBObject;
import com.mongodb.DBCollection;
import com.mongodb.ServerAddress;
import org.bson.types.ObjectId;

public class Runtime {
	String applicationName;
	Resolver resolver;
	MongoClient mongoClient;
	DB database;

	LinkedBlockingQueue<StackFrame> scheduledStackFrames;	

	public Runtime(String applicationName) throws UnknownHostException {
		this(applicationName, new Resolver());
	}

	public Runtime(String applicationName, Resolver resolver) throws UnknownHostException {
		this.applicationName = applicationName;
		this.resolver = resolver;
		this.scheduledStackFrames = new LinkedBlockingQueue<StackFrame>();
		this.mongoClient = new MongoClient(new ServerAddress("localhost", 27017));
		this.database = mongoClient.getDB(this.applicationName);

		// TODO: Add the indices to the mongo database.
	}

	public Resolver getResolver() {
		return resolver;
	}

	public DB getDatabase() {
		return database;
	}

	public void start(String startUpSymbol) {
		BasicDBObject query = new BasicDBObject("symbol_name", startUpSymbol);

		if(database.getCollection(new StackFrame().collectionName()).findOne(query) == null) {
			StackFrame root = new StackFrame(startUpSymbol, this.resolver);
			// TODO: Remove this and refactor the API
			root.setRuntime(this);
			root.save();
		}

		BasicDBObject frameQuery = new BasicDBObject("state", StackFrame.RUNNING);
		BasicDBObject frameSort = new BasicDBObject("created_at", -1);
		
		DBCursor frames = database.getCollection(new StackFrame().collectionName()).find(frameQuery).sort(frameSort);
		for(DBObject frame : frames) {
			StackFrame stackFrame = new StackFrame();
			stackFrame.fromMongo(frame, this.resolver);
			this.schedule(stackFrame);
		}
		
		this.resume();
	}

	public void restart(String startUpSymbol) {
		database.getCollection(new StackFrame().collectionName()).drop();
		database.getCollection(new Future(this).collectionName()).drop();
		this.start(startUpSymbol);
	}

	public void reset() {
		for(String collection : database.getCollectionNames()) {
			try {
				database.getCollection(collection).drop();
			} catch(Exception e) {
				
			}
		}
	}

	public ArrayList<StackFrame> build(String symbol) {
		Type instance = (Type)resolver.resolveSymbol(symbol);
		ArrayList<Value> arguments = new ArrayList<Value>();
		arguments.add(instance);

		return this.invoke(symbol, arguments);
	}

	public ArrayList<StackFrame> invoke(String symbol) {
		return this.invoke(symbol, new ArrayList<Value>(), null);
	}

	public ArrayList<StackFrame> invoke(String symbol, List<Value> arguments) {
		return this.invoke(symbol, arguments, null);
	}

	public ArrayList<StackFrame> invoke(String symbol, List<Value> arguments, StackFrame parentStackFrame) {
		StackFrame frame = new StackFrame(symbol, resolver);

		this.schedule(frame);
		return this.resume();
	}

	public void schedule(StackFrame frame) {
		// TODO - I need to set the StackFrame's status to PENDING...
		for(StackFrame f : scheduledStackFrames) {
			if(f.getId().equals(frame.getId())) {
				return;
			}
		}

		scheduledStackFrames.offer(frame);
	}

	public ArrayList<StackFrame> resume() {
		LinkedHashMap<ObjectId, StackFrame> stackTraceHeads = new LinkedHashMap<ObjectId, StackFrame>();

		// TODO - I need to set the StackFrame's status to RUNNING...

		while(!scheduledStackFrames.isEmpty()) {
			StackFrame frame = scheduledStackFrames.poll();

			while(true) {
				try {
					frame.setRuntime(this);
					Signal signal = frame.resume();

					if(signal.type == Signal.Type.RETURN) {
						if(frame.controlAncestors.size() == 0) {
							stackTraceHeads.put(frame.getId(), frame);

							if(frame.isRoot()) {
								frame.save();
							}

							break;
						} else {
							StackFrame returnFrame = (StackFrame)frame.controlAncestors.get(frame.controlAncestors.size() - 1);
							if(returnFrame.returnRegister != -1) {
								if(frame.returnRegister != -1) {
									returnFrame.registers[returnFrame.returnRegister] = frame.registers[frame.returnRegister];
								} else {
									returnFrame.registers[returnFrame.returnRegister] = new NullValue();
								}
							}

							frame.remove();
							frame = returnFrame;
						}
					} else if (signal.type == Signal.Type.INVOKE) {
						StackFrame newFrame = signal.stackFrame;
						newFrame.controlAncestors = new ArrayList<Object>(frame.controlAncestors);
						newFrame.controlAncestors.add(frame);
						frame = newFrame;
					} else if (signal.type == Signal.Type.SCHEDULE) {
						// TODO: Handle return values...
						StackFrame newFrame = signal.stackFrame;
						this.schedule(newFrame);
					} else if (signal.type == Signal.Type.PAUSE) {

					} else if (signal.type == Signal.Type.STOP) {

					} else if (signal.type == Signal.Type.EXIT) {

					}
				} catch(WaitingException e) {
					DBCollection collection = this.database.getCollection(new Future(this).collectionName());

					BasicDBObject query = new BasicDBObject("value_id", e.futureValueId);
					BasicDBObject update = new BasicDBObject("$push", new BasicDBObject("blocking_stack_frames", frame.getId()));

					collection.update(query, update, false, true);

					frame.returnRegister = e.returnRegister;
					frame.state = StackFrame.WAITING;
					frame.save();
				}
			}
		}

		return new ArrayList<StackFrame>(stackTraceHeads.values());
	}
}

