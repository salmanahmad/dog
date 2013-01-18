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

/*
 TODO: Constants have been deprecated and removed from the langauge for the time being.
 If you want to achieve similar results just create a function:

 define PI do
	3.14159
 end

 The reason for this is that there is nothing you can't achieve with Functions that you
 can achieve with Constants. Functions as Constants can encode the "can't change" me
 semantics because you cannot redefine a function at runtime anyways. Second of all, 
 Constants have the major limitation that it cannot use any runtime types. For example,
 it would be impossible to do this:

 define cool_person = person { 
 	name = "Bob" 
 }
 
 because the compiler does not know about the "person" type. It just knows about langauge
 literals. It also means that you cannot do this:

 define cool_person = person {
	age = compute_number_less_than: 100	
 }

 because it requires a function call that you cannot do in the compilation phase.

 Admittedly, the only thing that you could do with constants that you cannot do with functions
 is the notion that "the first time you assign it, it cannot change". However, you *COULD* achieve
 this same result with a "global_data" collection and just coordinate access to it from a function.
 Basically, you could implement constants easily with runtime capabilities of the language
 so why build it into the runtime explicitly? The only reason could be performance but
 I don't see them being that useful to the extent that they would get enough usage to
 warrant the performance optimization.

 */

public class Constant {
	public Value value() {
		return null;
	}
}
