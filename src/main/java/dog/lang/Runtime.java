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
import dog.lang.runtime.APIServlet;

import java.util.concurrent.LinkedBlockingQueue;
import java.util.LinkedHashMap;
import java.util.ArrayList;
import java.util.List;
import java.net.UnknownHostException;
import java.net.URL;

import com.mongodb.MongoClient;
import com.mongodb.DB;
import com.mongodb.DBCursor;
import com.mongodb.DBObject;
import com.mongodb.BasicDBObject;
import com.mongodb.DBCollection;
import com.mongodb.ServerAddress;
import org.bson.types.ObjectId;

import org.eclipse.jetty.server.Server;

public class Runtime {
	String applicationName;
	String applicationPath;
	String startUpSymbol;
	Resolver resolver;
	MongoClient mongoClient;
	DB database;

	LinkedBlockingQueue<StackFrame> scheduledStackFrames;	

	public Runtime(String applicationName) throws UnknownHostException {
		this(applicationName, System.getProperty("user.dir"), new Resolver());
	}

	public Runtime(String applicationName, Resolver resolver) throws UnknownHostException {
		this(applicationName, System.getProperty("user.dir"), resolver);
	}

	public Runtime(String applicationName, String applicationPath) throws UnknownHostException {
		this(applicationName, applicationPath, new Resolver());
	}

	public Runtime(String applicationName, String applicationPath, Resolver resolver) throws UnknownHostException {
		this.applicationName = applicationName;
		this.applicationPath = applicationPath;
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

	public String getStartUpSymbol() {
		return startUpSymbol;
	}

	public void start(String startUpSymbol) {
		this.startUpSymbol = startUpSymbol;

		BasicDBObject rootQuery = new BasicDBObject("symbol_name", startUpSymbol);

		if(database.getCollection(new StackFrame().collectionName()).findOne(rootQuery) == null) {
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

		
		frames = database.getCollection(new StackFrame().collectionName()).find(new BasicDBObject("state", StackFrame.WAITING));

		StackFrame root = new StackFrame();
		// TODO: Move the runtime into the constructor of the stackframe
		root.setRuntime(this);
		root.findOne(rootQuery);

		if(frames.count() > 0 || root.getMetaData().get("listens") != null) {
			APIServlet servlet = new APIServlet(this, "dog", this.applicationPath + "/views");
			Server server = APIServlet.createServer(4242, servlet);
			try {
				server.start();
				server.join();
			} catch(Exception e) {
				System.out.println("Could not start API server.");
			}
		}
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
					stackTraceHeads.remove(frame.getId());
					frame.setRuntime(this);
					frame.state = StackFrame.RUNNING;
					Signal signal = frame.resume();


					if(signal.type == Signal.Type.RETURN) {
						frame.state = StackFrame.FINISHED;

						if(frame.controlAncestors.size() == 0) {
							stackTraceHeads.put(frame.getId(), frame);

							if(frame.isRoot()) {
								frame.save();
							} else {
								if(frame.futureReturnId != null) {
									StructureValue value = new StructureValue();
									value.setId(frame.futureReturnId);
									value.pending = true;

									Value returnValue = new NullValue();
									if(frame.returnRegister != -1) {
										returnValue = frame.registers[frame.returnRegister];
									}

									StackFrame completeFutureStackFrame = new StackFrame("future.complete_future:with:", getResolver(), new Value[] {value, returnValue});
									this.schedule(completeFutureStackFrame);
								}

								frame.remove();
							}

							break;
						} else {
							StackFrame returnFrame = frame.parentStackFrame();
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
						frame.state = StackFrame.CALLING;

						StackFrame newFrame = signal.stackFrame;
						newFrame.controlAncestors = new ArrayList<Object>(frame.controlAncestors);
						newFrame.controlAncestors.add(frame);
						frame = newFrame;
					} else if (signal.type == Signal.Type.SCHEDULE) {
						StructureValue futureValue = new StructureValue();
						futureValue.pending = true;
						futureValue.channelMode = false;
						futureValue.channelSize = 0;

						Future future = new Future(this);
						future.valueId = futureValue.getId();
						future.save();

						StackFrame newFrame = signal.stackFrame;
						newFrame.futureReturnId = futureValue.getId();
						this.schedule(newFrame);

						frame.registers[frame.returnRegister] = futureValue;
					} else if (signal.type == Signal.Type.PAUSE) {

					} else if (signal.type == Signal.Type.STOP) {

					} else if (signal.type == Signal.Type.EXIT) {

					}
				} catch(ImplicitWaitException e) {
					DBCollection collection = this.database.getCollection(new Future(this).collectionName());

					BasicDBObject query = new BasicDBObject("value_id", e.futureValueId);
					BasicDBObject update = new BasicDBObject("$push", new BasicDBObject("blocking_stack_frames", frame.getId()));
					collection.update(query, update, false, true);

					frame.returnRegister = e.returnRegister;
					frame.state = StackFrame.WAITING;
					frame.save();

					stackTraceHeads.put(frame.getId(), frame);

					break;
				} catch(WaitOnException e) {
					DBCollection collection = this.database.getCollection(new Future(this).collectionName());

					ArrayList<Future> awaitedFutures = e.awaitedFutures;
					
					for(Future future : awaitedFutures) {
						BasicDBObject query = new BasicDBObject("_id", future.getId());
						BasicDBObject update = new BasicDBObject("$push", new BasicDBObject("broadcast_stack_frames", frame.getId()));
						collection.update(query, update, false, true);
					}
					
					frame.returnRegister = e.returnRegister;
					frame.state = StackFrame.WAITING;
					frame.save();

					stackTraceHeads.put(frame.getId(), frame);

					break;					
				}
			}
		}

		return new ArrayList<StackFrame>(stackTraceHeads.values());
	}
}

