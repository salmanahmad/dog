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
	public ObjectId futureId;
	public int returnRegister;
	

	public WaitingException(ObjectId futureId, int returnRegister) {
		this.futureId = futureId;
		this.returnRegister = returnRegister;
	}
	
}