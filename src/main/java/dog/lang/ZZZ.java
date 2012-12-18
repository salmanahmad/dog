

// This is a file that was added so I could disassemble it aand make it easier to generate JVM byte code...

import java.util.HashMap;

public class ZZZ extends dog.lang.Function {

	public HashMap<String, Integer> getVariableTable() {
		HashMap<String, Integer> map = new HashMap<String, Integer>();
		map.put("Hello", 1);
		map.put("Hi", 2);
		return map;
	};

	public int getRegisterCount() {
		return 2341;
	}

	public int getVariableCount() {
		return 2341;
	}

	public void test() {
		
	}

	public dog.lang.Signal resume(dog.lang.StackFrame stack) {
		

	

	
		

		switch(stack.programCounter) {
			case 0:
				stack.registers[999999].put(stack.registers[888888].getValue(), stack.registers[7777777]);
		}


		return new dog.lang.Signal(dog.lang.Signal.Type.INVOKE, new dog.lang.StackFrame(new dog.lang.Type(), new dog.lang.Value[] { new dog.lang.Type() }));
		//return new dog.lang.Signal(dog.lang.Signal.Type.RETURN);
		//return new dog.lang.Signal(dog.lang.Signal.Type.INVOKE, new dog.lang.StackFrame(new dog.lang.Function(), new dog.lang.Value[] {stack.registers[0], stack.registers[1], stack.registers[2], stack.registers[3]}));
	}
}