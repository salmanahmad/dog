/*
 *
 *  Copyright 2012 by Salman Ahmad (salman@salmanahmad.com).
 *  All rights reserved.
 *
 *  Permission is granted for use, copying, modification, distribution,
 *  and distribution of modified versions of this work as long as the
 *  above copyright notice is included.
 *
 */

package dog.lang;

import java.util.HashMap;
import org.json.JSONObject;
import com.mongodb.DBObject;

public class StackFrame extends DatabaseObject {

	public Class<? extends Continuable> symbol = null;

	public Value returnRegister = null;
	public Value[] registers = null;
	public Value[] variables = null;

	public int programCounter = 0;

	public HashMap<String, Integer> variableTable = new HashMap<String, Integer>();

	public StackFrame() {
		/* Keeping the default constructor so I can fromJSON and fromMongo */
	}

	public StackFrame(int registerCount, int variableCount) {
		registers = new Value[registerCount];
		variables = new Value[variableCount];
		programCounter = 0;
	}

	public String collectionName() {
		return "stack_frames";
	}

	public JSONObject toJSON() {
		return null;
	}

	public DBObject toMongo() {
		return null;
	}

	public void fromJSON(JSONObject json) {

	}

	public void fromMongo(DBObject bson) {

	}
}
