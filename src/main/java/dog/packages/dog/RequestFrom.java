package dog.packages.dog;

import dog.lang.Value;
import dog.lang.FalseValue;
import dog.lang.TrueValue;
import dog.lang.StringValue;
import dog.lang.StructureValue;
import dog.lang.NullValue;
import dog.lang.Function;
import dog.lang.Signal;
import dog.lang.StackFrame;
import dog.lang.annotation.Symbol;
import dog.packages.dog.Query;
import dog.packages.dog.Collection;

@Symbol("dog.request_from:")
public class RequestFrom extends Function {

	public int getVariableCount() {
		return 1;
	}

	public int getRegisterCount() {
		return 1;
	}

	public Signal resume(StackFrame frame) {
		if (frame.variables[0].request != null){
			frame.registers[0] = frame.variables[0].request;
		} else {
			frame.registers[0] = new NullValue();			
		}
		frame.returnRegister = 0;
		return new Signal(Signal.Type.RETURN);
	}
}

