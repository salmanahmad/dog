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

package dog.packages.future;

import dog.lang.Value;
import dog.lang.Runtime;
import dog.lang.StackFrame;
import dog.lang.Future;
import dog.lang.Function;
import dog.lang.Signal;
import dog.lang.StackFrame;
import dog.lang.annotation.Symbol;

import java.util.ArrayList;

import com.mongodb.BasicDBObject;
import org.bson.types.ObjectId;

@Symbol("future.send_value:to:")
public class SendValueTo extends Function {

	public int getVariableCount() {
		return 2;
	}

	public Signal resume(StackFrame frame) {
		Runtime runtime = frame.getRuntime();

		Value value = frame.variables[0];
		Value channel = frame.variables[1];

		if(channel.pending) {
			value.futureId = channel.getId();
			dog.lang.Future future = new dog.lang.Future(runtime);

			if(future.findOne(new BasicDBObject("value_id", channel.getId()))) {
				// TODO - Respect the queue_size if it is full. We need several backoff strategies
				// - Block
				// - Ignore
				// - Timeout
				// - Rollover least recently inserted (?) <- this may be problematic

				if(future.broadcastStackFrames.size() == 0 && future.handlers.size() == 0) {
					if(future.queueSize > 0) {
						future.queue.add(value);
						future.save();
					}
				} else {
					for(Object o : future.broadcastStackFrames) {
						ObjectId trackId = (ObjectId)o;
						
						StackFrame f = new StackFrame();
						f.setRuntime(runtime);
						boolean found = f.findOne(new BasicDBObject("_id", trackId));

						if(!found) {
							// TODO: Remove this _id from the future for the next function calls...
							continue;
						}

						// TODO: Ensure that my code is correct here. When I am waiting do I
						// use returnRegister to specify the register that I am expecting to be
						// filled out?
						int register = f.returnRegister;
						f.registers[register] = value;

						runtime.schedule(f);
					}

					for(String symbol : future.handlers) {
						StackFrame f = new StackFrame(symbol, runtime.getResolver(), new Value[] { value });
						runtime.schedule(f);
					}

					future.broadcastStackFrames = new ArrayList<Object>();
					future.save();
				}
			} else {
				// TODO: Error reporting or logging or some kind...
			}
		}
		
		
		return new Signal(Signal.Type.RETURN);
	}
}

