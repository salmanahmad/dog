/*
 *
 * @language java
 *
 */


package dog.packages.console;

import dog.lang.Value;
import dog.lang.StringValue;
import dog.lang.NullValue;
import dog.lang.Function;
import dog.lang.Signal;
import dog.lang.StackFrame;
import dog.lang.annotation.Symbol;

import java.util.Calendar;
import jline.console.ConsoleReader;

/*
 *
 * @module console
 * @method log:
 * @return {NullValue}
 *
 * Outputs the given message along with the date and the name
 * of the calling function.
 */
@Symbol("console.log:")
public class Log extends Function {

	static ConsoleReader console;

	public int getRegisterCount() {
		return 0;
	}

	public int getVariableCount() {
		return 1;
	}

	public Signal resume(StackFrame frame) {
		String value = frame.variables[0].toString();
		StackFrame callerFrame = frame.parentStackFrame();

		String caller = "<unknown>";

		if(callerFrame != null) {
			caller = callerFrame.symbolName;
		}


		Calendar now = Calendar.getInstance();
		String date = now.get(Calendar.YEAR) + "-" + 
					  now.get(Calendar.MONTH) + "-" + 
					  now.get(Calendar.DAY_OF_MONTH) + " " + 
					  now.get(Calendar.HOUR_OF_DAY) + ":" + 
					  now.get(Calendar.MINUTE) + ":" + 
					  now.get(Calendar.SECOND); 

		System.out.println("[" + date + " " + caller + "] " + value);
		return new Signal(Signal.Type.RETURN);
	}
}
