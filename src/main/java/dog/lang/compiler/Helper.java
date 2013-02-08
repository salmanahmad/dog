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

package dog.lang.compiler;

import dog.lang.compiler.Identifier;
import dog.lang.nodes.Node;
import dog.lang.nodes.StructureLiteral;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Set;

public class Helper {

	// TODO: Support the unary "not" operator in predicates. Right now I am removed them because there does not
	// seem to be a decent way in which I can negate a MongoDB query...
	public static StructureLiteral invertPredicateConditions(StructureLiteral literal) {
		HashMap inverseMapping = new HashMap();
		inverseMapping.put("$and", "$or");
		inverseMapping.put("$or", "$and");
		inverseMapping.put("$gte", "$lt");
		inverseMapping.put("$lte", "$gt");
		inverseMapping.put("$gt", "$lte");
		inverseMapping.put("$lt", "$gte");
		inverseMapping.put("$all", "$ne");
		inverseMapping.put("$ne", "$all");

		Identifier arrayIdentifier = new Identifier(Identifier.Scope.EXTERNAL, new ArrayList(Arrays.asList("dog", "array")));

		if(literal.type.equals(arrayIdentifier)) {
			Set keys = literal.value.keySet();
			for(Object key : keys) {
				Node node = literal.value.get(key);

				if(node instanceof StructureLiteral) {
					node = Helper.invertPredicateConditions((StructureLiteral)node);
				}

				literal.value.put(key, node);
			}			
		} else {
			HashMap<Object, Node> newValue = new HashMap<Object, Node>();

			Set keys = literal.value.keySet();
			for(Object operator : keys) {
				HashMap<Object, Node> body = new HashMap<Object, Node>(); 
				Node node = null;

				Object inverseOperator = inverseMapping.get(operator);
				
				if(inverseOperator == null) {
					node = literal.value.get(operator);
					body.put("$ne", node);

					newValue.put(operator, new StructureLiteral(body));
				} else {
					if(operator.equals("$all")) {
						node = ((StructureLiteral)literal.value.get(operator)).value.get(0.0);
						newValue.put(inverseOperator, node);
					} else if(operator.equals("$ne")) {
						node = literal.value.get(operator);
						body.put(0.0, node);
						newValue.put(inverseOperator, new StructureLiteral(arrayIdentifier, body));
					} else if(operator.equals("$and") || operator.equals("$or")) {
						node = literal.value.get(operator);

						if(node instanceof StructureLiteral) {
							node = Helper.invertPredicateConditions((StructureLiteral)node);
						}

						newValue.put(inverseOperator, node);
					} else {
						node = literal.value.get(operator);
						newValue.put(inverseOperator, node);
					}
				}
			}

			literal.value = newValue;
		}

		return literal;
	}

	public static ArrayList<Node> descendantsOfNode(Node node) {
		ArrayList<Node> descendants = new ArrayList<Node>();
		descendants.addAll(node.children());
		for(Node child : node.children()) {
			descendants.addAll(descendantsOfNode(child));
		}

		return descendants;
	}
}