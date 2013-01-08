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

package dog.lang.runtime;

import dog.lang.*;

import java.util.concurrent.LinkedBlockingQueue;
import java.util.LinkedHashMap;
import java.util.ArrayList;
import java.util.List;
import java.net.UnknownHostException;

import com.mongodb.MongoClient;
import com.mongodb.DB;
import com.mongodb.DBCollection;
import com.mongodb.ServerAddress;
import org.bson.types.ObjectId;

public class Runtime {
	Resolver resolver;
	LinkedBlockingQueue<StackFrame> scheduledStackFrames;
	
	MongoClient mongoClient;

	public Runtime() throws UnknownHostException {
		this(new Resolver());
	}

	public Runtime(Resolver resolver) throws UnknownHostException {
		this.resolver = resolver;
		scheduledStackFrames = new LinkedBlockingQueue<StackFrame>();
		mongoClient = new MongoClient(new ServerAddress("localhost", 27017));
	}

	public Resolver getResolver() {
		return resolver;
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
		for(StackFrame f : scheduledStackFrames) {
			if(f.getId().equals(frame.getId())) {
				return;
			}
		}

		scheduledStackFrames.offer(frame);
	}

	public ArrayList<StackFrame> resume() {
		LinkedHashMap<ObjectId, StackFrame> stackTraceHeads = new LinkedHashMap<ObjectId, StackFrame>();

		while(!scheduledStackFrames.isEmpty()) {
			StackFrame frame = scheduledStackFrames.poll();

			while(true) {
				Signal signal = frame.resume();

				if(signal.type == Signal.Type.RETURN) {
					// TODO: If returnRegister is -1 that means that you should just return NullValue
					if(frame.controlAncestors.size() == 0) {
						stackTraceHeads.put(frame.getId(), frame);
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
						
						frame = returnFrame;
					}
				} else if (signal.type == Signal.Type.INVOKE) {
					StackFrame newFrame = signal.stackFrame;
					newFrame.controlAncestors = new ArrayList<Object>(frame.controlAncestors);
					newFrame.controlAncestors.add(frame);
					frame = newFrame;
				} else if (signal.type == Signal.Type.SCHEDULE) {

				} else if (signal.type == Signal.Type.PAUSE) {

				} else if (signal.type == Signal.Type.STOP) {

				} else if (signal.type == Signal.Type.EXIT) {

				}
			}
		}

		return new ArrayList<StackFrame>(stackTraceHeads.values());
	}
}

