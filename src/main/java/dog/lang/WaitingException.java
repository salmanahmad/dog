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

import org.bson.types.ObjectId;

public class WaitingException extends RuntimeException {
	public ObjectId futureValueId;
	public int returnRegister;
	

	public WaitingException(ObjectId futureValueId, int returnRegister) {
		this.futureValueId = futureValueId;
		this.returnRegister = returnRegister;
	}
	
}