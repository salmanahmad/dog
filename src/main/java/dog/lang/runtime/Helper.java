package dog.lang.runtime;

import dog.lang.*;

import java.util.Map;

import org.json.JSONObject;
import org.json.JSONException;
import org.apache.commons.io.FilenameUtils;

public class Helper {
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