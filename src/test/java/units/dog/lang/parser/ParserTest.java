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


import org.junit.*;
import java.util.*;

import dog.lang.*;
import dog.lang.parser.*;
import dog.lang.nodes.*;

public class ParserTest {
    
    @Test
    public void testSimpleFunction() {
        Parser parser = new Parser();
        parser.parse("adsf safa fasdfa a(asdfa");
    }
}
