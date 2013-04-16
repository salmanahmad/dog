package dog.packages.console;

import dog.lang.Value;
import dog.lang.StringValue;
import dog.lang.NullValue;
import dog.lang.Function;
import dog.lang.Signal;
import dog.lang.StackFrame;
import dog.lang.annotation.Symbol;

import jline.console.ConsoleReader;

@Symbol("console.readLine:")
public class ReadLine extends Function {

	static ConsoleReader console;

	public int getRegisterCount() {
		return 1;
	}

	public int getVariableCount() {
		return 1;
	}

	public Signal resume(StackFrame frame) {
		String input = null;
		String prompt = ((StringValue)frame.variables[0]).value;
		try {
			if (console == null){
				console = new ConsoleReader();
			}
			console.setPrompt(prompt);
			input = console.readLine();
		}
		catch (java.io.IOException e){
			// This is gross, but forced by Java's silly exception
			// model.
			throw new RuntimeException("console IOError " + e.getMessage());
		}

		if (input == null){
			frame.registers[0] = new NullValue();
		} else {
			frame.registers[0] = new StringValue(input);
		}
		frame.returnRegister = 0;
		return new Signal(Signal.Type.RETURN);
	}
}

