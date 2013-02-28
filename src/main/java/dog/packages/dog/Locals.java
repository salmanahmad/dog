package dog.packages.dog;

import dog.lang.Value;
import dog.lang.NullValue;
import dog.lang.StructureValue;
import dog.lang.Function;
import dog.lang.Signal;
import dog.lang.StackFrame;
import dog.lang.annotation.Symbol;

@Symbol("dog.locals")
public class Locals extends Function {

	public int getRegisterCount() {
		return 1;
	}

	public Signal resume(StackFrame frame) {
		StructureValue output = new StructureValue();
		StackFrame parent = frame.parentStackFrame();
		frame.returnRegister = 0;
		frame.registers[0] = output;

		if (parent != null){
			for (String variable : parent.variableTable.keySet()){
				Value v = parent.variables[parent.variableTable.get(variable)];
				if (v == null){
					v = new NullValue();
				}
				output.value.put(variable, v);
			}
		}
		return new Signal(Signal.Type.RETURN);
	}
}

