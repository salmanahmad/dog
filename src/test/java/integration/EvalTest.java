import dog.lang.*;
import dog.lang.compiler.*;
import dog.lang.nodes.*;
import dog.util.Helper;

import org.junit.*;
import java.util.*;

public class EvalTest {
    
    @Test
    public void testBadArgument() {
		try {
			Helper.eval("dog_unit_tests", "dog.eval: 2").get(0);
			Assert.fail("dog.eval should throw an exception for any non-string argument");
		} catch (RuntimeException e){
			Assert.assertEquals("dog.eval: expects a string", e.getMessage());
		}
    }

	@Test
	public void testSimpleEvaluation() {
		StackFrame frame = Helper.eval("dog_unit_tests", "dog.eval: '1.0+1.0'").get(0);
		Value output = frame.registers[frame.returnRegister];
		Assert.assertTrue("output is a number", output instanceof NumberValue);
		Assert.assertEquals(2.0, output.getValue());
	}

	@Test
	public void testSymbolAccess() {
		String source = Helper.readResource("/integrations/EvalTest/symbol_access.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", source).get(0);
		Value output = frame.registers[frame.returnRegister];
		Assert.assertEquals(43.0, output.getValue());
	}

	@Test
	public void testSymbolCreation() {
		String source = Helper.readResource("/integrations/EvalTest/symbol_creation.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", source).get(0);
		Value output = frame.registers[frame.returnRegister];
		Assert.assertEquals(43.0, output.getValue());
	}

	@Test
	public void testVariableAccess() {
		String source = Helper.readResource("/integrations/EvalTest/variable_access.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", source).get(0);
		Value output = frame.registers[frame.returnRegister];
		Assert.assertEquals(43.0, output.getValue());
	}


	@Test
	public void testMultiVariableAccess() {
		String source = Helper.readResource("/integrations/EvalTest/multi_variable_access.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", source).get(0);
		Value output = frame.registers[frame.returnRegister];
		Assert.assertEquals("foobar", output.getValue());
	}

	@Test
	public void testVariableCreation() {
		String source = Helper.readResource("/integrations/EvalTest/variable_creation.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", source).get(0);
		Value output = frame.registers[frame.returnRegister];
		Assert.assertEquals(43.0, output.getValue());
	}

	@Test
	public void testVariableUpdate() {
		String source = Helper.readResource("/integrations/EvalTest/variable_update.dog");
		StackFrame frame = Helper.eval("dog_unit_tests", source).get(0);
		Value output = frame.registers[frame.returnRegister];
		Assert.assertEquals(43.0, output.getValue());
	}


}
