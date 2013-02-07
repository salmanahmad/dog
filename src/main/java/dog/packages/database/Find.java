
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

@Symbol("database.find:")
public class Find extends Function {

	public int getRegisterCount() {
		return 1;
	}

	public int getVariableCount() {
		return 1;
	}

	public Signal resume(StackFrame frame) {
		Value returnValue = new TrueValue();
		Value arg = frame.variables[0];
		
		if(arg instanceof dog.packages.dog.Query) {
			dog.packages.dog.Query query = (dog.packages.dog.Query)arg;

			DB database = frame.getRuntime().getDatabase();
			DBCollection dbCollection = database.getCollection(((StringValue)query.get("container").get("name")).value);

			try {
				DBCursor results = dbCollection.find(dog.lang.runtime.Helper.dogStructureAsMongoQuery((StructureValue)query.get("predicate")));

				StructureValue array = (StructureValue)frame.getRuntime().getResolver().resolveSymbol("dog.array");
				double index = 0;

				for(DBObject result : results) {
					array.put(index, Value.createFromMongo(result, frame.getRuntime().getResolver()));
					index++;
				}

				returnValue = array;
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

