
package dog.packages.dog;

import dog.lang.Value;
import dog.lang.Type;
import dog.lang.Signal;
import dog.lang.StackFrame;
import dog.lang.annotation.Symbol;

import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;
import java.util.TreeSet;
import java.util.SortedSet;

@Symbol("dog.predicate")
public class Predicate extends Type {
	public Signal resume(StackFrame frame) {
		frame.registers[0] = frame.variables[0];
		frame.returnRegister = 0;

		Signal signal = new Signal(Signal.Type.RETURN);
		return signal;
	}
}

