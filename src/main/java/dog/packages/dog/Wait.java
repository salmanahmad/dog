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

package dog.packages.dog;

import dog.lang.Value;
import dog.lang.Future;
import dog.lang.StructureValue;
import dog.lang.Function;
import dog.lang.Signal;
import dog.lang.StackFrame;
import dog.lang.annotation.Symbol;

import java.util.Map;
import java.util.HashMap;
import java.util.ArrayList;

import com.mongodb.BasicDBObject;
import org.bson.types.ObjectId;

@Symbol("dog.wait:")
public class Wait extends Function {

	public int getRegisterCount() {
		return 1;
	}

	public int getVariableCount() {
		return 1;
	}

	public Signal resume(StackFrame frame) {
		if(frame.programCounter == 0) {
			// First time being called.
			frame.programCounter++;

			Class listenerClass = frame.getRuntime().getResolver().classForSymbol("dog.listener");

			Value arg = frame.variables[0];
			if(arg instanceof StructureValue) {
				StructureValue array = (StructureValue)arg;

				// First check if we are lucky and are waiting on a value that is already
				// known and is not pending...

				for(Object key : ((HashMap<Object, Value>)array.getValue()).keySet()) {
					Value value = array.get(key);

					if(listenerClass.isAssignableFrom(value.getClass())) {
						value = value.get("channel");
					}

					if(!value.pending) {
						frame.registers[0] = value;
						frame.returnRegister = 0;
						return new Signal(Signal.Type.RETURN);
					}
				}

				ArrayList<Value> awaitedValues = new ArrayList<Value>();
				ArrayList<Future> awaitedFutures = new ArrayList<Future>();

				for(Object key : ((HashMap<Object, Value>)array.getValue()).keySet()) {
					Value originalValue = array.get(key);
					Value value = null;
					boolean isListen = false;

					if(listenerClass.isAssignableFrom(originalValue.getClass())) {
						value = originalValue.get("channel");
						isListen = true;
					} else {
						value = originalValue;
					}

					Future future = new Future(frame.getRuntime());
					future.findOne(new BasicDBObject("value_id", value.getId()));

					if(future.value != null) {
						Value returnValue = future.value;
						
						frame.registers[0] = returnValue;
						frame.returnRegister = 0;
						return new Signal(Signal.Type.RETURN);
					} else if(future.queue.size() > 0) {
						Value returnValue = future.queue.remove(0);
						future.save();

						frame.registers[0] = returnValue;
						frame.returnRegister = 0;
						return new Signal(Signal.Type.RETURN);
					} else {
						awaitedValues.add(value);
						awaitedFutures.add(future);

						if(isListen) {
							StackFrame currentFrame = frame.parentStackFrame();
							Map<String, Value> meta = currentFrame.getMetaData();

							if(meta.get("listens") == null) {
								meta.put("listens", new StructureValue());
							}

							StructureValue listens = (StructureValue)meta.get("listens");
							StructureValue listen = (StructureValue)originalValue;

							listens.put(listen.get("identifier").getValue(), listen);
						}
					}
				}

				frame.returnRegister = 0;
				throw new dog.lang.WaitOnException(awaitedFutures, frame.returnRegister);
			}

			return new Signal(Signal.Type.RETURN);
		} else {
			// Second time being called. 
			frame.programCounter++;

			// We now know that the return value
			// is in frame.register[frame.returnRegister] so we can just return...
			return new Signal(Signal.Type.RETURN);
		}
	}
}

