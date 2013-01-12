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

import java.util.ArrayList;

public class WaitOnException extends RuntimeException {
	public ArrayList<Future> awaitedFutures;
	public int returnRegister;
	

	public WaitOnException(ArrayList<Future> awaitedFutures, int returnRegister) {
		this.awaitedFutures = awaitedFutures;
		this.returnRegister = returnRegister;
	}
	
}