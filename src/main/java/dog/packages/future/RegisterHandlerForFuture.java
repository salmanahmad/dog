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
import dog.lang.StringValue;
import dog.lang.Function;
import dog.lang.Signal;
import dog.lang.StackFrame;
import dog.lang.annotation.Symbol;

import com.mongodb.BasicDBObject;

@Symbol("future.register_handler:for_future:")
public class RegisterHandlerForFuture extends Function {

	public int getVariableCount() {
		return 2;
	}


	// TODO: This should expose the listen to the meta...
	
	public Signal resume(StackFrame frame) {
		Value handler = frame.variables[0];
		Value future = frame.variables[1];

		if(future.pending && handler instanceof StringValue) {
			// TODO: Make this an atomic $push update...
			dog.lang.Future f = new dog.lang.Future(frame.getRuntime());
			f.findOne(new BasicDBObject("value_id", future.getId()));
			f.handlers.add((String)handler.getValue());
			f.save();
		}

		return new Signal(Signal.Type.RETURN);
	}
}

