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
import org.bson.types.ObjectId;

public class StackFrame extends DatabaseObject {

	public Continuable symbol = null;
	public String symbolName = null;

	public Value returnRegister = null;
	public Value[] registers = null;
	public Value[] variables = null;

	public int programCounter = 0;

	public HashMap<String, Integer> variableTable = new HashMap<String, Integer>();

	ObjectId id;

	public StackFrame() {
		/* Keeping the default constructor so I can fromJSON and fromMongo */
	}

	public StackFrame(Continuable symbol) {
		this.symbol = symbol;
		this.symbolName = Resolver.decodeSymbol(symbol.getClass().getName());
		this.initialize(symbol.getRegisterCount(), symbol.getVariableCount(), symbol.getVariableTable());
	}

	public StackFrame(String symbolName, Resolver resolver) {
		Continuable symbol = (Continuable)resolver.resolveSymbol(symbolName);
		this.symbolName = symbolName;
		this.symbol = symbol;
		this.initialize(symbol.getRegisterCount(), symbol.getVariableCount(), symbol.getVariableTable());
	}

	protected void initialize(int registerCount, int variableCount, HashMap<String, Integer> variableTable) {
		this.registers = new Value[registerCount];
		this.variables = new Value[variableCount];
		this.variableTable = variableTable;
		this.programCounter = 0;
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
