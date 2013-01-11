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

@Symbol("future.complete_future:with:")
public class CompleteFutureWith extends Function {

	public int getVariableCount() {
		return 2;
	}

	public Signal resume(StackFrame frame) {
		Runtime runtime = frame.getRuntime();

		Value future = frame.variables[0];
		Value value = frame.variables[1];
		
		if(future.pending) {
			value.futureId = future.getId();
			Future f = new Future(runtime);

			if(f.findOne(new BasicDBObject("value_id", future.getId()))) {

				for(Object o : f.blockingStackFrames) {
					ObjectId trackId = (ObjectId)o;
					
					StackFrame stackFrame = new StackFrame();
					stackFrame.setRuntime(runtime);
					stackFrame.findOne(new BasicDBObject("_id", trackId));

					// TODO: Consider having a similar thing to broadcast where you
					// send the value back by using the returnRegister. That could
					// be a useful calling convention.

					runtime.schedule(stackFrame);
				}

				for(Object o : f.broadcastStackFrames) {
					ObjectId trackId = (ObjectId)o;
					
					StackFrame stackFrame = new StackFrame();
					stackFrame.setRuntime(runtime);
					stackFrame.findOne(new BasicDBObject("_id", trackId));

					// TODO: Ensure that my code is correct here. When I am waiting do I
					// use returnRegister to specify the register that I am expecting to be
					// filled out?
					stackFrame.registers[stackFrame.returnRegister] = value;

					runtime.schedule(stackFrame);
				}

				for(String symbol : f.handlers) {
					StackFrame stackFrame = new StackFrame(symbol, runtime.getResolver(), new Value[] { value });
					runtime.schedule(stackFrame);
				}

				f.value = value;

				f.blockingStackFrames = new ArrayList<Object>();
				f.broadcastStackFrames = new ArrayList<Object>();

				f.save();

			}
		}


		return new Signal(Signal.Type.RETURN);
	}
}

