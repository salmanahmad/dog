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

import java.lang.Math;
import java.util.Map;
import java.util.List;
import java.util.HashMap;
import java.util.ArrayList;

import org.json.JSONObject;
import com.mongodb.DBObject;
import com.mongodb.BasicDBObject;
import com.mongodb.MongoClient;
import com.mongodb.DB;
import com.mongodb.DBCollection;
import org.bson.types.ObjectId;

public class StackFrame extends DatabaseObject {
	ObjectId id;
	ObjectId futureReturnId;

	public Continuable symbol = null;
	public String symbolName = null;

	// TODO: If the return Register is -1 it means null...
	public int returnRegister = -1;
	public int programCounter = 0;

	// TODO: Consider tracking registers, variables, and arguments. 
	// They will be initialized with registerCount, variableCount, and argumentCount
	// that way I can check for cases where you pass in more than the correct
	// number of arguments to a function.

	public Value[] registers = null;
	public Value[] variables = null;

	public HashMap<String, Integer> variableTable = new HashMap<String, Integer>();
	public ArrayList<Object> controlAncestors = new ArrayList<Object>();

	public StackFrame() {
		// Keeping the default constructor so I can fromJSON and fromMongo
	}

	public StackFrame(Continuable symbol) {
		this(symbol, new Value[] {});
	}

	public StackFrame(Continuable symbol, Value[] arguments) {
		this.symbol = symbol;
		this.symbolName = Resolver.decodeSymbol(Resolver.convertJavaClassNameToJVMClassName(symbol.getClass().getName()));
		this.initialize(symbol.getRegisterCount(), symbol.getVariableCount(), symbol.getVariableTable(), arguments);
	}

	public StackFrame(String symbolName, Resolver resolver) {
		this(symbolName, resolver, new Value[] {});
	}

	public StackFrame(String symbolName, Resolver resolver, Value[] arguments) {
		Continuable symbol = (Continuable)resolver.resolveSymbol(symbolName);
		this.symbolName = symbolName;
		this.symbol = symbol;
		this.initialize(symbol.getRegisterCount(), symbol.getVariableCount(), symbol.getVariableTable(), arguments);
	}

	protected void initialize(int registerCount, int variableCount, HashMap<String, Integer> variableTable, Value[] arguments) {
		this.registers = new Value[registerCount];
		this.variables = new Value[variableCount];
		this.variableTable = variableTable;
		this.programCounter = 0;

		for(int i = 0; i < Math.min(this.variables.length, arguments.length) ; i++) {
			this.variables[i] = arguments[i];
		}
	}

	public String collectionName() {
		return "stack_frames";
	}

	public ObjectId getId() {
		if (this.id == null) {
            this.id = new ObjectId();
        }

        return this.id;
	}

	public Signal resume() {
		return symbol.resume(this);
	}

	public Value getVariableNamed(String name) {
		return this.variables[this.variableTable.get(name)];
	}

	public StackFrame parentStackFrame() {
		if(this.controlAncestors.size() == 0) {
			return null;
		} else {
			Object object = this.controlAncestors.get(this.controlAncestors.size() - 1);
			if(object instanceof StackFrame) {
				return (StackFrame)object;
			} else if(object instanceof ObjectId) {
				BasicDBObject query = new BasicDBObject();
				query.put("_id", (ObjectId)object);

				DBCollection collection = this.getCollection();
				DBObject data = collection.findOne(query);

				StackFrame parent = new StackFrame();
				parent.setRuntime(this.getRuntime());
				parent.fromMongo(data, this.getRuntime().getResolver());
				
				return parent;
			} else {
				return null;
			}
		}
	}

	public boolean isRoot() {
		if(this.symbolName.split("\\.").equals("@root")) {
			return true;
		} else {
			return false;
		}
	}

	public Map toMap() {
		return toMongo().toMap();
	}

	public JSONObject toJSON() {
		return null;
	}

	public DBObject toMongo() {
		BasicDBObject hash = new BasicDBObject();
		hash.put("_id", this.getId());
		hash.put("future_return_id", this.futureReturnId);
		hash.put("symbol_name", this.symbolName);

		hash.put("program_counter", this.programCounter);
		hash.put("return_register", this.returnRegister);
        
        ArrayList<DBObject> registers = new ArrayList<DBObject>();
        for(Value register : this.registers) {
        	registers.add(register.toMongo());
        }

		ArrayList<DBObject> variables = new ArrayList<DBObject>();
		for(Value variable : this.variables) {
			variables.add(variable.toMongo());
		}

        hash.put("registers", registers);
		hash.put("variables", variables); 

		ArrayList<ObjectId> controlAncestors = new ArrayList<ObjectId>();
		for(Object controlAncestor : this.controlAncestors) {
			if(controlAncestor instanceof StackFrame) {
				StackFrame controlAncestorFrame = (StackFrame)controlAncestor;

				controlAncestorFrame.setRuntime(runtime);
				controlAncestorFrame.save();
				controlAncestors.add(controlAncestorFrame.getId());
			} else if(controlAncestor instanceof ObjectId) {
				controlAncestors.add((ObjectId)controlAncestor);
			}
		}

		hash.put("variable_table", new BasicDBObject(this.variableTable));
		hash.put("control_ancestors", controlAncestors);

		return hash;
	}

	public void fromMap(Map map, Resolver resolver) {
		this.fromMongo(new BasicDBObject(map), resolver);
	}

	public void fromJSON(JSONObject json, Resolver resolver) {
		
	}

	public void fromMongo(DBObject bson, Resolver resolver) {
		this.id = (ObjectId)bson.get("_id");
		this.futureReturnId = (ObjectId)bson.get("future_return_id");
		this.symbolName = (String)bson.get("symbol_name");

		this.programCounter = (Integer)bson.get("program_counter");
		this.returnRegister = (Integer)bson.get("return_register");

		ArrayList<Value> registersList = new ArrayList<Value>();
		for(DBObject object : (List<DBObject>)bson.get("registers")) {
			registersList.add(Value.createFromMongo(object, resolver));
		}

		ArrayList<Value> variablesList = new ArrayList<Value>();
		for(DBObject object : (List<DBObject>)bson.get("variables")) {
			variablesList.add(Value.createFromMongo(object, resolver));
		}

		this.registers = new Value[registersList.size()];
		this.variables = new Value[variablesList.size()];

		for(int i = 0; i < registers.length; i++) {
			this.registers[i] = registersList.get(i);
		}

		for(int i = 0; i < variables.length; i++) {
			this.variables[i] = variablesList.get(i);
		}

		this.variableTable = new HashMap<String, Integer>();
		this.controlAncestors = new ArrayList<Object>();

		Map variableTableMap = (Map)bson.get("variable_table");
		for(Object key : variableTableMap.keySet()) {
			String stringKey = (String)key;
			this.variableTable.put(stringKey, (Integer)variableTableMap.get(key));
		}

		for(Object object : (List)bson.get("control_ancestors")) {
			this.controlAncestors.add(object);
		}
	}
}
