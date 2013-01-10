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
import java.util.Date;

import org.json.JSONObject;
import com.mongodb.DBObject;
import com.mongodb.BasicDBObject;
import com.mongodb.MongoClient;
import com.mongodb.DB;
import com.mongodb.DBCollection;
import org.bson.types.ObjectId;

public class StackFrame extends DatabaseObject {
	
	public static String RUNNING = "running";
	public static String CALLING = "calling";
	public static String WAITING = "waiting";
	public static String FINISHED = "finished";

	ObjectId futureReturnId;

	public Continuable symbol = null;
	public String symbolName = null;
	
	String state;
	Date createdAt;

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

	// TODO: Right now the constructors take a reference to the Resolver, however those should be a runtime reference
	// shouldn't they? And the runtime field should be set rather than having to rely on the setRuntime call from
	// the Runtime class

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

		this.state = StackFrame.RUNNING;
		this.createdAt = new Date();

		for(int i = 0; i < Math.min(this.variables.length, arguments.length) ; i++) {
			this.variables[i] = arguments[i];
		}
	}

	public StackFrame(ObjectId id, Runtime runtime) {
		BasicDBObject query = new BasicDBObject();
		query.put("_id", id);

		DBCollection collection = this.getCollection();
		DBObject data = collection.findOne(query);

		this.setRuntime(runtime);
		this.fromMongo(data, this.getRuntime().getResolver());
	}

	public String collectionName() {
		return "stack_frames";
	}

	public void setState(String state) {
		this.state = state;
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
				return new StackFrame((ObjectId)object, this.getRuntime());
			} else {
				return null;
			}
		}
	}

	public boolean isRoot() {
		String[] components = this.symbolName.split("\\.");
		if(components[components.length - 1].equals("@root")) {
			return true;
		} else {
			return false;
		}
	}

	// TODO: Right now in toMongo() it always saves all of the controlAncestors
	// to mongo. However, I don't always want to do that. In some cases I want to
	// have a normal memory-based execution model like a normal langauge. In those
	// cases toMap() should not serialize the controlAncestors into ObjectIds

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
		hash.put("state", this.state);
		hash.put("created_at", this.createdAt);

		hash.put("program_counter", this.programCounter);
		hash.put("return_register", this.returnRegister);
        
        ArrayList<DBObject> registers = new ArrayList<DBObject>();
        for(Value register : this.registers) {
        	if(register != null) {
        		registers.add(register.toMongo());
        	} else {
        		registers.add(null);
        	}
        	
        }

		ArrayList<DBObject> variables = new ArrayList<DBObject>();
		for(Value variable : this.variables) {
			if(variable != null) {
				variables.add(variable.toMongo());
			} else {
				variables.add(null);
			}
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
		this.symbol = (Continuable)resolver.resolveSymbol(this.symbolName);

		this.state = (String)bson.get("state");
		this.createdAt = (Date)bson.get("created_at");

		this.programCounter = (Integer)bson.get("program_counter");
		this.returnRegister = (Integer)bson.get("return_register");

		ArrayList<Value> registersList = new ArrayList<Value>();
		for(Object object : (List)bson.get("registers")) {
			if(object == null) {
				registersList.add(null);
			} else {
				registersList.add(Value.createFromMongo((DBObject)object, resolver));
			}
		}

		ArrayList<Value> variablesList = new ArrayList<Value>();
		for(Object object : (List)bson.get("variables")) {
			if(object == null) {
				variablesList.add(null);
			} else {
				variablesList.add(Value.createFromMongo((DBObject)object, resolver));
			}
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
