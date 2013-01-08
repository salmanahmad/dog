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
import java.util.HashMap;
import java.util.ArrayList;

import org.json.JSONObject;
import org.bson.types.ObjectId;
import com.mongodb.DBObject;
import com.mongodb.BasicDBObject;

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
				// TODO - How do I search for the object?
				return null;
			} else {
				return null;
			}
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
		hash.put("_id", this.futureReturnId);
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

		hash.put("variable_table", new BasicDBObject(this.variableTable));
		// TODO: How do I save my control ancestors...?
		hash.put("control_ancestors", this.controlAncestors);

		return hash;
	}

	public void fromMap(Map map, Resolver resolver) {
		this.fromMongo(new BasicDBObject(map), resolver);
	}

	public void fromJSON(JSONObject json, Resolver resolver) {
		// TODO
	}

	public void fromMongo(DBObject bson, Resolver resolver) {
		
	}
}
