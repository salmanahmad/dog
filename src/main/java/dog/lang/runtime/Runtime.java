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
import java.util.ArrayList;
import java.util.List;

public class Runtime {

	Resolver resolver;
	LinkedBlockingQueue<StackFrame> scheduledStackFrames;

	public Runtime() {
		this(new Resolver());
	}

	public Runtime(Resolver resolver) {
		this.resolver = resolver;
		resolver.linkNativeCode();
		scheduledStackFrames = new LinkedBlockingQueue<StackFrame>();
	}

	public StackFrame invoke(String symbol) {
		return this.invoke(symbol, new ArrayList<Value>(), null);
	}

	public StackFrame invoke(String symbol, List<Value> arguments) {
		return this.invoke(symbol, arguments, null);
	}

	public StackFrame invoke(String symbol, List<Value> arguments, StackFrame parentStackFrame) {
		StackFrame frame = new StackFrame(symbol, resolver);

		this.schedule(frame);
		this.resume();

		return frame;
	}

	public void schedule(StackFrame frame) {
		for(StackFrame f : scheduledStackFrames) {
			if(f.getId().equals(frame.getId())) {
				return;
			}
		}

		scheduledStackFrames.offer(frame);
	}

	public void resume() {
		while(!scheduledStackFrames.isEmpty()) {
			StackFrame frame = scheduledStackFrames.poll();
			frame.resume();
		}
	}
}

