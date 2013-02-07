
package dog.packages.collection;

import dog.lang.Value;
import dog.lang.FalseValue;
import dog.lang.TrueValue;
import dog.lang.StringValue;
import dog.lang.Function;
import dog.lang.Signal;
import dog.lang.StackFrame;
import dog.lang.annotation.Symbol;

@Symbol("database.save:to:")
public class Save extends Function {

	public int getRegisterCount() {
		return 1;
	}

	public int getVariableCount() {
		return 2;
	}

	public Signal resume(StackFrame frame) {

		Value returnValue = new TrueValue();
		Value value = frame.variables[0];
		
		frame.returnRegister = 0;
		frame.registers[0] = returnValue;
		
		return new Signal(Signal.Type.RETURN);
	}
}

