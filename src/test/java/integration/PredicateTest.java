
import dog.lang.*;
import dog.lang.compiler.*;
import dog.lang.nodes.*;
import dog.util.Helper;

import org.junit.*;
import java.util.*;

public class PredicateTest {
    
    @Test
    public void testSimple() {
        Resolver resolver = new Resolver();
        StructureValue predicate = (StructureValue)resolver.resolveSymbol("dog.predicate");
        predicate.putAll("value", new StructureValue(
            "$elemMatch", new StructureValue(
                "value.value", new NumberValue(8.0),
                "key", new StringValue("age")
            )
        ));

		StackFrame frame = Helper.eval("dog_unit_tests", "i = where age == 8").get(0);

		StructureValue i = (StructureValue)frame.getVariableNamed("i");

		Assert.assertTrue(i instanceof dog.packages.dog.Predicate);
        Assert.assertTrue(i.equalTo(predicate) instanceof TrueValue);
    }

    @Test
    public void testAnd() {
        Resolver resolver = new Resolver();
        StructureValue predicate = (StructureValue)resolver.resolveSymbol("dog.predicate");
        predicate.putAll("$and", new StructureValue(
            0.0, new StructureValue(
                "value", new StructureValue(
                    "$elemMatch", new StructureValue(
                        "value.value", new NumberValue(8.0),
                        "key", new StringValue("age")
                    )
                )
            ),
            1.0, new StructureValue(
                "value", new StructureValue(
                    "$elemMatch", new StructureValue(
                        "value.value", new StructureValue("$lt", new NumberValue(8.0)),
                        "key", new StringValue("height")
                    )
                )
            )
        ));

        StackFrame frame = Helper.eval("dog_unit_tests", "i = where age == 8 && height < 8").get(0);



        StructureValue i = (StructureValue)frame.getVariableNamed("i");
        Assert.assertTrue(i instanceof dog.packages.dog.Predicate);
        Assert.assertTrue(i.equalTo(predicate) instanceof TrueValue);
    }

    @Test
    public void testOr() {
        Resolver resolver = new Resolver();
        StructureValue predicate = (StructureValue)resolver.resolveSymbol("dog.predicate");
        predicate.putAll("$or", new StructureValue(
            0.0, new StructureValue(
                "value", new StructureValue(
                    "$elemMatch", new StructureValue(
                        "value.value", new NumberValue(8.0),
                        "key", new StringValue("age")
                    )
                )
            ),
            1.0, new StructureValue(
                "value", new StructureValue(
                    "$elemMatch", new StructureValue(
                        "value.value", new StructureValue("$gte", new NumberValue(8.0)),
                        "key", new StringValue("height")
                    )
                )
            )
        ));

        StackFrame frame = Helper.eval("dog_unit_tests", "i = where age == 8 || height >= 8").get(0);

        StructureValue i = (StructureValue)frame.getVariableNamed("i");
        Assert.assertTrue(i instanceof dog.packages.dog.Predicate);
        Assert.assertTrue(i.equalTo(predicate) instanceof TrueValue);
    }
}
