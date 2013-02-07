
package dog.packages.collection;

import dog.lang.Value;
import dog.lang.FalseValue;
import dog.lang.TrueValue;
import dog.lang.StringValue;
import dog.lang.StructureValue;
import dog.lang.Function;
import dog.lang.Signal;
import dog.lang.StackFrame;
import dog.lang.annotation.Symbol;

import com.mongodb.MongoClient;
import com.mongodb.DB;
import com.mongodb.DBCursor;
import com.mongodb.DBObject;
import com.mongodb.BasicDBObject;
import com.mongodb.DBCollection;
import com.mongodb.MongoException;
import org.bson.types.ObjectId;

@Symbol("database.save:to:")
public class Save extends Function {

	public int getRegisterCount() {
		return 1;
	}

	public int getVariableCount() {
		return 2;
	}

	public Signal resume(StackFrame frame) {
		Value returnValue = new TrueValue();
		
		Value arg1 = frame.variables[0];
		Value arg2 = frame.variables[1];

		if(arg1 instanceof StructureValue && arg2 instanceof dog.packages.dog.Collection) {
			StructureValue value = (StructureValue)arg1;
			StructureValue collection = (StructureValue)arg2;

			DB database = frame.getRuntime().getDatabase();
			DBCollection dbCollection = database.getCollection(((StringValue)collection.get("name")).value);

			try {
				dbCollection.save(value.toMongo());
				returnValue = value;
			} catch(MongoException e) {
				returnValue = new FalseValue();
			}
		} else {
			returnValue = new FalseValue();
		}

		frame.returnRegister = 0;
		frame.registers[0] = returnValue;
		
		return new Signal(Signal.Type.RETURN);
	}
}

