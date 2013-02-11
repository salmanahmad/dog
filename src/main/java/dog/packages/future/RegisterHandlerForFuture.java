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
import dog.lang.StructureValue;
import dog.lang.Function;
import dog.lang.Signal;
import dog.lang.StackFrame;
import dog.lang.annotation.Symbol;

import java.util.Map;

import com.mongodb.BasicDBObject;

@Symbol("future.register_handler:for_future:")
public class RegisterHandlerForFuture extends Function {

	public int getVariableCount() {
		return 2;
	}

	public Signal resume(StackFrame frame) {
		Value handler = frame.variables[0];
		Value future = frame.variables[1];

		Class listenerClass = frame.getRuntime().getResolver().classForSymbol("dog.listener");

		if(handler instanceof StringValue) {
			StructureValue listen = null;
			
			if(listenerClass.isAssignableFrom(future.getClass())) {
				listen = (StructureValue)future;
				future = future.get("channel");
			}

			if(future.pending) {
				// TODO: Make this an atomic $push update...
				dog.lang.Future f = new dog.lang.Future(frame.getRuntime());
				f.findOne(new BasicDBObject("value_id", future.getId()));
				f.handlers.add((String)handler.getValue());
				f.save();

				if(listen != null) {
					StackFrame currentFrame = frame.parentStackFrame();
					Map<String, Value> meta = currentFrame.getMetaData();

					if(meta.get("listens") == null) {
						meta.put("listens", new StructureValue());
					}

					StructureValue listens = (StructureValue)meta.get("listens");

					listens.put(listen.get("identifier").getValue(), listen);
				}
			}
		}

		return new Signal(Signal.Type.RETURN);
	}
}

