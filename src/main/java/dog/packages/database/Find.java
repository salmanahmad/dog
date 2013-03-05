
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
import dog.packages.dog.Query;
import dog.packages.dog.Collection;

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

	DBCollection dbCollection(DB database, Value collection) {
		String name = ((StringValue)(((Collection)collection).get("name"))).value;
		return database.getCollection(name);
	}

	DBCursor find(DB database, Value input) {
		if (input instanceof Collection) {
			return dbCollection(database, input).find();
		}
		if (input instanceof Query) {
			Query query = (Query)input;
			DBCollection collection = dbCollection(database, query.get("container"));
			return collection.find(dog.lang.runtime.Helper.dogStructureAsMongoQuery((StructureValue)query.get("predicate")));
		}
		return null;
	}

	public Signal resume(StackFrame frame) {
		Value returnValue = new TrueValue();

		try {
			DBCursor results = find(frame.getRuntime().getDatabase(), frame.variables[0]);
			if (results == null){
				returnValue = new FalseValue();
			} else {
				StructureValue array = (StructureValue)frame.getRuntime().getResolver().resolveSymbol("dog.array");
				double index = 0;
				for(DBObject result : results) {
					array.put(index, Value.createFromMongo(result, frame.getRuntime().getResolver()));
					index++;
				}
				returnValue = array;
			}
		} catch(MongoException e) {
			returnValue = new FalseValue();
		}

		frame.returnRegister = 0;
		frame.registers[0] = returnValue;
		
		return new Signal(Signal.Type.RETURN);
	}
}

