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

package dog.packages.reflect;

import dog.lang.Value;
import dog.lang.Function;
import dog.lang.Signal;
import dog.lang.Resolver;
import dog.lang.StackFrame;
import dog.lang.annotation.Symbol;

import java.util.Arrays;
import java.util.ArrayList;

import org.apache.commons.lang3.StringUtils;

@Symbol("reflect.current_package")
public class CurrentPackage extends Function {

	public int getRegisterCount() {
		return 1;
	}

	public Signal resume(StackFrame frame) {
		String name = null;

		if(frame.controlAncestors.size() != 0) {
			// TODO: Update this with StackFrame.parentStackFrame
			StackFrame returnFrame = (StackFrame)frame.controlAncestors.get(frame.controlAncestors.size() - 1);

			ArrayList<String> list = new ArrayList<String>(Arrays.asList(StringUtils.split(returnFrame.symbolName, ".")));
			list.remove(list.size() - 1);
			name = StringUtils.join(list, ".");
		}

		Resolver r = (Resolver)this.getClass().getClassLoader();
		
		dog.packages.dog.Package p = (dog.packages.dog.Package)r.resolveSymbol("dog.package");
		p.setName(name);

		frame.registers[0] = p;
		frame.returnRegister = 0;

		return new Signal(Signal.Type.RETURN);
	}
}

