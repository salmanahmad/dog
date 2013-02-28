import dog.lang.*;
import dog.util.Helper;

import org.junit.*;
import java.util.*;

public class LocalsTest {
    @Test
    public void testBadArgument() {
		StackFrame frame = Helper.eval("dog_unit_tests", "a = 1; b = 'mystring'; c = null; dog.locals").get(0);
		Value output = frame.registers[frame.returnRegister];
		Assert.assertTrue("output is a structure", output instanceof StructureValue);
		StructureValue sv = (StructureValue) output;
		Assert.assertEquals(3, sv.value.size());
		Assert.assertTrue("a is a number", sv.value.get("a") instanceof NumberValue);
		Assert.assertTrue("b is a string", sv.value.get("b") instanceof StringValue);
		Assert.assertTrue("c is null", sv.value.get("c") instanceof NullValue);
    }
}
