package dog.lang.runtime;

import dog.lang.*;
import dog.packages.dog.Array;

import java.util.Map;
import java.util.ArrayList;
import com.mongodb.BasicDBObject;
import java.util.TreeSet;
import java.util.SortedSet;
import java.util.Arrays;

import org.json.JSONObject;
import org.json.JSONException;
import org.apache.commons.io.FilenameUtils;

public class Helper {
	public static BasicDBObject dogStructureAsMongoQuery(StructureValue structure) {
		BasicDBObject query = new BasicDBObject();

		for(Object key : structure.value.keySet()) {
			Value value = structure.value.get(key);

			if(value instanceof dog.packages.dog.Array) {
				query.put(key.toString(), dogArrayAsJavaList((dog.packages.dog.Array)value));
			} else if (value instanceof StructureValue) {
				query.put(key.toString(), dogStructureAsMongoQuery((StructureValue)value));
			} else {
				query.put(key.toString(), value.getValue());
			}
		}

		return query;
	}

	public static ArrayList dogArrayAsJavaList(dog.packages.dog.Array array) {
		ArrayList list = new ArrayList();
		SortedSet<Object> keys = new TreeSet<Object>(array.value.keySet());

		for(Object key : keys) {
			Value value = array.value.get(key);

			if(value instanceof dog.packages.dog.Array) {
				list.add(dogArrayAsJavaList((dog.packages.dog.Array)value));
			} else if (value instanceof StructureValue) {
				list.add(dogStructureAsMongoQuery((StructureValue)value));
			} else {
				list.add(value.getValue());
			}
		}

		return list;
	}
	public static dog.packages.dog.Array javaListAsArray(ArrayList array){
		ArrayList toConvert = array;
		int size = toConvert.size();

		Array dogArray = new Array();

		for (int i = 0; i < size; i++){
			Value temp = (Value) toConvert.get(i);
			Object index = (double) i;
			dogArray.put(index, temp);
		}

		return dogArray;
	}

	public static JSONObject stackFrameAsJsonForAPI(StackFrame frame) {
		JSONObject object = new JSONObject();
		try {
			object.put("_id", frame.getId().toString());
			object.put("state", frame.state);
			object.put("symbol_name", frame.symbolName);
			
			Map<String, Value> meta = frame.getMetaData();

			if(meta.get("displays") != null) {
				JSONObject jsonDisplays = new JSONObject();
				StructureValue displays = (StructureValue)meta.get("displays");

				for(Object key : displays.value.keySet()) {
					StructureValue display = (StructureValue)displays.value.get(key);
					jsonDisplays.put(key.toString(), display.get("value").toJSON());
				}

				object.put("displays", jsonDisplays);
			}

			if(meta.get("listens") != null) {
				JSONObject jsonListens = new JSONObject();
				StructureValue listens = (StructureValue)meta.get("listens");

				for(Object key : listens.value.keySet()) {
					jsonListens.put(key.toString(), new JSONObject());
				}

				object.put("listens", jsonListens);
			}

			if(frame.state.equals(StackFrame.FINISHED)) {
				object.put("returns", frame.registers[frame.returnRegister].toJSON());			
			}
		} catch(JSONException e) {
			object = new JSONObject();
			System.out.println(e);
		}
		

		return object;
	}
}