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

public class StructureValue extends Value {

	public HashMap<Object, Value> value = new HashMap<Object, Value>();

    public StructureValue() {
        super();
    }

	public StructureValue(HashMap<Object, Value> v) {
        super();
        value = v;
    }
    
    public Object getValue() {
        return value;
    }

	public Value get(Object key) {
        Value v = this.value.get(key);
        
        if(v == null) {
            return new NullValue();
        } else {
            return v;
        }
    }

    public void put(Object key, Value value) {
        if((key instanceof Number) || (key instanceof String)) {
			this.value.put(key, value);
		}
    }

    public boolean isStructure() {
        return true;
    }
}

