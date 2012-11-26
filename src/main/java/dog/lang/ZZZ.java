

public class ZZZ extends dog.lang.Function {
	public int getRegisterCount() {
		return 2341;
	}

	public int getVariableCount() {
		return 2341;
	}

	public dog.lang.Signal resume(dog.lang.StackFrame stack) {

		switch(stack.programCounter) {
			case 0:
				stack.registers[3452] = stack.registers[9999].plus(stack.registers[1000]);
				
			case 1:
				stack.programCounter++;
			case 5: 
				
			case 2: 
				
			
		}


		return new dog.lang.Signal(dog.lang.Signal.Type.RETURN, stack);
	}
}