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
import java.util.HashMap;
import java.util.ArrayList;

import org.json.JSONObject;
import org.bson.types.ObjectId;
import com.mongodb.DBObject;

public class StackFrame extends DatabaseObject {

	ObjectId id;
	ObjectId futureReturnId;

	public Continuable symbol = null;
	public String symbolName = null;

	// TODO: Consider tracking registers, variables, and arguments. 
	// They will be initialized with registerCount, variableCount, and argumentCount
	// that way I can check for cases where you pass in more than the correct
	// number of arguments to a function.

	public Value[] registers = null;
	public Value[] variables = null;
	
	// TODO: If the return Register is -1 it means null...
	public int returnRegister = -1;
	public int programCounter = 0;

	public HashMap<String, Integer> variableTable = new HashMap<String, Integer>();
	public ArrayList<Object> controlAncestors = new ArrayList<Object>();

	public StackFrame() {
		/* Keeping the default constructor so I can fromJSON and fromMongo */
	}

	public StackFrame(Continuable symbol) {
		this(symbol, new Value[] {});
	}

	public StackFrame(Continuable symbol, Value[] arguments) {
		this.symbol = symbol;
		this.symbolName = Resolver.decodeSymbol(symbol.getClass().getName());
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

	public JSONObject toJSON() {
		return null;
	}

	public DBObject toMongo() {
		return null;
	}

	public void fromJSON(JSONObject json, Resolver resolver) {

	}

	public void fromMongo(DBObject bson, Resolver resolver) {

	}
}
