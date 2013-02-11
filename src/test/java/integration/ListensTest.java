import dog.lang.*;
import dog.lang.compiler.*;
import dog.lang.nodes.*;
import dog.util.Helper;

import org.junit.*;
import java.util.*;

public class ListensTest {
    
    @Test
    public void testSimple() {
        String source = "i = dog.listen_to: dog.everyone for: \"monkies\"";
        StackFrame frame = Helper.eval("dog_unit_tests", source).get(0);        


        StructureValue i = (StructureValue)frame.getVariableNamed("i");
        Assert.assertEquals("monkies", i.get("name").getValue());
        Assert.assertFalse(i.get("channel") instanceof NullValue);
        Assert.assertFalse(i.get("routing") instanceof NullValue);
    }
}
