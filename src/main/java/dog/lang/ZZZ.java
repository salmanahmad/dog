

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
		
		if(stack.registers[5000].booleanEquivalent()) {
			stack.programCounter = 5000;
		} else {
			stack.programCounter++;
		}
		
		switch(stack.programCounter) {
			case 0:
				stack.registers[1] = stack.registers[0];
			case 1:
				stack.registers[2] = stack.registers[0];
			case 2:
				stack.registers[3] = stack.registers[0];
			case 3:
				stack.registers[4] = stack.registers[0];
		}


		return new dog.lang.Signal(dog.lang.Signal.Type.RETURN, stack);
	}
}