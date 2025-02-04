
grammar Grammar;

options {
  output = AST;
  backtrack=true;
  ASTLabelType=CommonTree;
}

@parser::header { 
package dog.lang.parser.grammar;

import dog.lang.nodes.*;
import dog.lang.compiler.Identifier;
import dog.lang.parser.ParseError;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Arrays;

}

@lexer::header {
package dog.lang.parser.grammar;
import dog.lang.nodes.*;
import dog.lang.parser.LexError;
}

@parser::members {
    // TODO - Better error reporting here --- http://www.antlr.org/wiki/display/ANTLR3/Error+reporting+and+recovery
    public void emitErrorMessage(String message) {
        throw new ParseError(message);
    }
}


@lexer::members {
    // TODO - Better error reporting here --- http://www.antlr.org/wiki/display/ANTLR3/Error+reporting+and+recovery
    public void emitErrorMessage(String message) {
        throw new LexError(message);
    }
}

program returns [Nodes nodes]
  : terminator? expressions? EOF! { $nodes = $expressions.nodes; }
  ;
	
expressions returns [Nodes nodes]
	:                      { $nodes = new Nodes(); }
    head=expression      { $nodes.add($head.node); }
    (
      terminator         
	    tail=expression    { $nodes.add($tail.node); }
	  )*
	  terminator
  ;

expression returns [Node node]
	: assignmentExpression { $node = $assignmentExpression.node; }
  ;

assignmentExpression returns [Node node]
  : assignment             { $node = $assignment.node; }
  | e=orExpression         { $node = $e.node; }
  ;
  
orExpression returns [Node node]
  : n1=andExpression      { $node = $n1.node; }
    ( OR
      n2=orExpression     { $node = new Operation($start.getLine(), $n1.node, $n2.node, "||"); }
    )?
  ;

andExpression returns [Node node]
  : n1=relationalExpression { $node = $n1.node; }
    ( AND
      n2=andExpression      { $node = new Operation($start.getLine(), $n1.node, $n2.node, "&&"); }
    )?
  ;

relationalExpression returns [Node node]
  : n1=additiveExpression     { $node = $n1.node; }
    ( relationalOperator
      n2=relationalExpression { $node = new Operation($start.getLine(), $n1.node, $n2.node, $relationalOperator.text); }
    )?
  ;

additiveExpression returns [Node node]
  : n1=multiplicativeExpression   { $node = $n1.node; }
    ( additiveOperator
      n2=additiveExpression       { $node = new Operation($start.getLine(), $n1.node, $n2.node, $additiveOperator.text); }
    )?
  ;

multiplicativeExpression returns [Node node]
  : n1=unaryExpresion             { $node = $n1.node; }
    ( multiplicativeOperator
      n2=multiplicativeExpression { $node = new Operation($start.getLine(), $n1.node, $n2.node, $multiplicativeOperator.text); }
    )?
  ;

unaryExpresion returns [Node node]
  : NOT node1=unaryExpresion      { $node = new Operation($start.getLine(), $node1.node, null, "!"); }
  | queryExpression               { $node = $queryExpression.node; }
  ;

queryExpression returns [Node node] 
@init {
  Identifier predicateIdentifier = new Identifier(Identifier.Scope.EXTERNAL, new ArrayList(Arrays.asList("dog", "predicate")));
  Identifier queryIdentifier = new Identifier(Identifier.Scope.EXTERNAL, new ArrayList(Arrays.asList("dog", "query")));
  Identifier arrayIdentifier = new Identifier(Identifier.Scope.EXTERNAL, new ArrayList(Arrays.asList("dog", "array"))); 

  HashMap<Object, Node> query = new HashMap<Object, Node>();
}
  : primaryExpression 
    predicateStatement {
      query.put("container", $primaryExpression.node);
      query.put("predicate", $predicateStatement.node);

      $node = new StructureLiteral(queryIdentifier, query);
    }
  | primaryExpression { 
      $node = $primaryExpression.node; 
    }
  ;

primaryExpression returns [Node node]
  : literal                   { $node = $literal.node; }
  | access                    { $node = $access.node; }
  | call                      { $node = $call.node; }
  | functionDefinition        { $node = $functionDefinition.node; }
  | structureDefinition       { $node = $structureDefinition.node; }
  | collectionDefinition      { $node = $collectionDefinition.node; }
  | controlStructure          { $node = $controlStructure.node; }
  | timingStructure           { $node = $timingStructure.node; }
  | waitStatement             { $node = $waitStatement.node; }
  | spawnStatement            { $node = $spawnStatement.node; }
  | packageDeclaration        { $node = $packageDeclaration.node; }
  | includeStatement          { $node = $includeStatement.node; }
  | onEachStatement           { $node = $onEachStatement.node; }
  | onStatement               { $node = $onStatement.node; }
  | predicateStatement        { $node = $predicateStatement.node; }
  ;

assignment returns [Node node]
@init{ ArrayList<Object> path = new ArrayList<Object>(); }
  : IDENTIFIER      { path.add($IDENTIFIER.text); }
    ( accessPath    { path.addAll($accessPath.path); }
    )?
    ASSIGN 
    expression      { $node = new Assign($start.getLine(), path, $expression.node); }
  ;

access returns [Node node]
@init{ Identifier.Scope scope = Identifier.Scope.CASCADE; ArrayList<Object> path = new ArrayList<Object>(); }
  :                                        
    ( literal                             { path.add($literal.node); }
    | OPEN_PAREN expression CLOSE_PAREN   { path.add($expression.node); }
    | identifierPath                      { path.addAll($identifierPath.identifier.path); scope = $identifierPath.identifier.scope; } 
    )
    ( accessPath                          { path.addAll($accessPath.path); }
    )?                                    { $node = new Access($start.getLine(), scope, path); }
  ;

accessPath returns [ArrayList<Object> path]
  : accessDot         { $path = $accessDot.path; }
  | accessBracket     { $path = $accessBracket.path; }
  ;

accessDot returns [ArrayList<Object> path]
  : DOT               { $path = new ArrayList<Object>(); }
    IDENTIFIER        { $path.add($IDENTIFIER.text); }
    ( accessPath      { $path.addAll($accessPath.path); }
    )?
  ;

accessBracket returns [ArrayList<Object> path]
  : OPEN_BRACKET      { $path = new ArrayList<Object>(); }
    expression        { $path.add($expression.node); }
    CLOSE_BRACKET
    ( accessPath      { $path.addAll($accessPath.path); }
    )?
  ;

identifierPath returns [Identifier identifier]
  :                    { $identifier =  new Identifier(); }
                       { $identifier.scope = Identifier.Scope.CASCADE; }
    ( CASCADE          { $identifier.scope = Identifier.Scope.CASCADE; }
    | EXTERNAL         { $identifier.scope = Identifier.Scope.EXTERNAL; }
    | INTERNAL         { $identifier.scope = Identifier.Scope.INTERNAL; }
    | LOCAL            { $identifier.scope = Identifier.Scope.LOCAL; }
    )?              
    head=IDENTIFIER    { $identifier.path.add($head.getText()); }
    ( DOT
      tail=IDENTIFIER  { $identifier.path.add($tail.getText()); }
    )*              
  ;

packageIdentifier returns [ArrayList<String> identifier]
  :                    { $identifier =  new ArrayList<String>(); }
    head=IDENTIFIER    { $identifier.add($head.getText()); }
    ( DOT
      tail=IDENTIFIER  { $identifier.add($tail.getText()); }
    )*              
  ;

call returns [Node node]
@init { ArrayList<Node> arguments = new ArrayList<Node>(); Identifier path = new Identifier(); String name = ""; }
  : ( identifierPath             { path = $identifierPath.identifier; }
      DOT
    )?
    headParam=PARAMETER          { name += $headParam.getText(); }
    head=expression              { arguments.add($head.node); }
    ( tailParam=PARAMETER        { name += $tailParam.getText(); }
      tail=expression            { arguments.add($tail.node); }
    )*                           { path.path.add(name); $node = new Call($start.getLine(), false, path, arguments); }
  ;

spawnStatement returns [Node node]
@init { ArrayList<String> path = new ArrayList<String>(); Access a = null; }
  : SPAWN
    ( access                  { 
                                a = (Access)$access.node;
                                for(Object o : a.getPath()) {
                                  path.add((String)o);
                                }

                                $node = new Call($start.getLine(), true, new Identifier(a.getScope(), path), new ArrayList<Node>()); 
                              }
    | call                    { $node = $call.node; ((Call)$node).setAsynchronous(true); }
    )
  ;

functionDefinition returns [Node node]
  : functionWithArguments        { $node = $functionWithArguments.node; }
  | functionWithoutArguments     { $node = $functionWithoutArguments.node; }
  ;

functionWithArguments returns [Node node]
@init { String name = ""; ArrayList<String> args = new ArrayList<String>(); Node body = new Nodes(); }
  : DEFINE                       
    headParam=PARAMETER          { name += $headParam.getText(); }
    headId=IDENTIFIER            { args.add($headId.getText()); }
    ( tailParam=PARAMETER        { name += $tailParam.getText(); }
      tailId=IDENTIFIER          { args.add($tailId.getText()); }
    )*
    DO terminator? 
    ( expressions                { body = $expressions.nodes; }
    )?
    END                          { $node = new FunctionDefinition($start.getLine(), name, args, body); }
  ;

functionWithoutArguments returns [Node node]
@init { String name = ""; ArrayList<String> args = new ArrayList<String>(); Node body = new Nodes(); }
  : DEFINE
    IDENTIFIER                   { name += $IDENTIFIER.text; }
    DO terminator?
    ( expressions                { body = $expressions.nodes; }
    )?
    END                          { $node = new FunctionDefinition($start.getLine(), name, args, body); }
  ;

structureDefinition returns [Node node]
@init { String name = ""; HashMap<Object, Node> properties = new HashMap<Object, Node>(); }
  : DEFINE
    IDENTIFIER                        { name = $IDENTIFIER.text; }
    NEWLINE* OPEN_BRACE NEWLINE*
    ( terminator?
      head=structureAssociation       { properties.put($head.key, $head.node); }
      ( (COMMA | terminator)
        tail=structureAssociation     { properties.put($tail.key, $tail.node); }
      )*
    )?
    NEWLINE* CLOSE_BRACE              { $node = new StructureDefinition($start.getLine(), name, properties); }
  ;

collectionDefinition returns [Node node]
@init { String name = ""; Nodes body = new Nodes(); HashMap<Object, Node> value = new HashMap<Object, Node>(); }
  : DEFINE
    COLLECTION
    IDENTIFIER            { name = $IDENTIFIER.text; }
                          { 
                            value.put("name", new Operation(
                              $start.getLine(),
                              new Access($start.getLine(), 
                                Identifier.Scope.LOCAL,
                                new ArrayList<Object>(Arrays.asList("p", "name"))
                              ),
                              new StringLiteral($start.getLine(), "." + $IDENTIFIER.text),
                              "+"
                            ));
                          }
                          { 
                            body.add(new Assign(
                              $start.getLine(), 
                              new ArrayList<Object>(Arrays.asList("p")),
                              new Call(
                                $start.getLine(),
                                false,
                                new Identifier(Identifier.Scope.EXTERNAL, new ArrayList<String>(Arrays.asList("reflect", "current_package"))),
                                new ArrayList<Node>()
                              )
                            ));

                            body.add(new StructureLiteral(
                                $start.getLine(), 
                                new Identifier(Identifier.Scope.EXTERNAL, new ArrayList<String>(Arrays.asList("dog", "collection"))),
                                value
                            ));
                          }

                          { $node = new FunctionDefinition($start.getLine(), name, new ArrayList<String>(), body); }
  ;

controlStructure returns [Node node]
  : ifStatement           { $node = $ifStatement.node; }
  | forLoop               { $node = $forLoop.node; }  
  | whileLoop             { $node = $whileLoop.node; }  
  | repeatLoop            { $node = $repeatLoop.node; } 
  | foreverLoop           { $node = $foreverLoop.node; }  
  | breakStatement        { $node = $breakStatement.node; }   
  | returnStatement       { $node = $returnStatement.node; }    
  ;

ifStatement returns [Node node]
@init { 
  Node condition = null; 
  Nodes trueBranch = null; 
  Nodes falseBranch = null; 
  Nodes falseBranchPointer = null; 
  Nodes temp = null;  
}
  : IF 
    expression                { condition = $expression.node; }
    (THEN | DO) terminator?
    ( expressions             { trueBranch = $expressions.nodes; }
    )?
    ( elseIfStatement         { if(falseBranch == null) { falseBranch = new Nodes(); falseBranchPointer = falseBranch; } }
                              { temp = new Nodes(); }
                              { falseBranchPointer.add(new Branch($elseIfStatement.condition, $elseIfStatement.nodes, temp)); }
                              { falseBranchPointer = temp; }
    )*
    ( elseStatement           { if(falseBranch == null) { falseBranch = new Nodes(); falseBranchPointer = falseBranch; } }
                              { falseBranchPointer.add($elseStatement.nodes);  }
    )?
    END                       { $node = new Branch($start.getLine(), condition, trueBranch, falseBranch); }
  ;

elseIfStatement returns [Node condition, Nodes nodes]
  : ELSE 
    IF                          { $nodes = null; }
    expression                  { $condition = $expression.node; }
    (THEN | DO) terminator?
    ( expressions               { $nodes = $expressions.nodes; }
    )?
  ;

elseStatement returns [Nodes nodes]
  : ELSE terminator?
    ( expressions               { $nodes = $expressions.nodes; }
    )?
  ;


forLoop returns [Node node]
@init {
  String keysVariableName = "@keys" + dog.util.Helper.uniqueNumber();
  String sizeVariableName = "@size" + dog.util.Helper.uniqueNumber();
  String counterVariableName = "@counter" + dog.util.Helper.uniqueNumber();
  String structureVariableName = "@structure" + + dog.util.Helper.uniqueNumber();
  
  String localLoopVariable = "";
  Node expression = null;
  Nodes body = null;
  Nodes nodes = new Nodes();

  Identifier keysId = new Identifier(Identifier.Scope.EXTERNAL, new ArrayList<String>(Arrays.asList("dog", "structure_keys:")));
  Identifier sizeId = new Identifier(Identifier.Scope.EXTERNAL, new ArrayList<String>(Arrays.asList("dog", "structure_size:")));
}
  : FOR EACH
    IDENTIFIER        { localLoopVariable = $IDENTIFIER.text; }
    IN
    expression        { expression = $expression.node; }
    DO terminator?
    ( expressions     { body = $expressions.nodes; }
    )?
    END               {

      nodes.add(new Nodes(new ArrayList<Node>(Arrays.asList(
        new Assign(
          new ArrayList<Object>(Arrays.asList(structureVariableName)),
          expression
        ),
        new Assign(
          new ArrayList<Object>(Arrays.asList(keysVariableName)),
          new Call(
            false,
            keysId,
            new ArrayList<Node>(Arrays.asList(
              new Access(Identifier.Scope.LOCAL, new ArrayList<Object>(Arrays.asList(structureVariableName)))
            ))
          )
        ),
        new Assign(
          new ArrayList<Object>(Arrays.asList(sizeVariableName)),
          new Call(
            false,
            sizeId,
            new ArrayList<Node>(Arrays.asList(
              new Access(Identifier.Scope.LOCAL, new ArrayList<Object>(Arrays.asList(keysVariableName)))
            ))
          )
        ),
        new Assign(
          $start.getLine(), 
          new ArrayList(Arrays.asList(counterVariableName)),
          new NumberLiteral($start.getLine(), 0)
        ),
        new Loop(
          new Nodes(new ArrayList<Node>(Arrays.asList(
            new Branch(
              new Operation(
                new Access(Identifier.Scope.LOCAL, new ArrayList<Object>(Arrays.asList(counterVariableName))),
                new Access(Identifier.Scope.LOCAL, new ArrayList<Object>(Arrays.asList(sizeVariableName))),
                "<"
              ),
              new Nodes(new ArrayList<Node>(Arrays.asList(
                new Assign(
                  new ArrayList(Arrays.asList(localLoopVariable)),
                  new Access(
                    Identifier.Scope.LOCAL,
                    new ArrayList<Object>(Arrays.asList(
                      keysVariableName,
                      new Access(Identifier.Scope.LOCAL, new ArrayList<Object>(Arrays.asList(counterVariableName)))
                    ))
                  )
                ),
                body,
                new Assign(
                  new ArrayList(Arrays.asList(counterVariableName)),
                  new Operation(
                    new Access(Identifier.Scope.LOCAL, new ArrayList<Object>(Arrays.asList(counterVariableName))),
                    new NumberLiteral($start.getLine(), 1),
                    "+"
                  )
                )
              ))),
              new Break(null)
            )
          )))
        )
      ))));

      $node = nodes;
    }
  ;

whileLoop returns [Node node]
@init { Node body = null; }
  : WHILE
    expression
    DO terminator?
    ( expressions                 { body = $expressions.nodes; }
    )?
    END {
      $node = new Loop($start.getLine(),
        new Branch($start.getLine(),
          $expression.node,
          body,
          new Break($start.getLine(), null)
        )
      );
    }
  ;

repeatLoop returns [Node node]
@init { Node body = null; String counterVariable = "@counter" + dog.util.Helper.uniqueNumber(); }
  : REPEAT
    expression
    (TIMES | DO) terminator?
    ( expressions                 { body = $expressions.nodes; }
    )?
    END {
      $node = new Nodes(
        new ArrayList<Node>(Arrays.asList(
          new Assign(
            $start.getLine(), 
            new ArrayList(Arrays.asList(counterVariable)),
            new NumberLiteral($start.getLine(), 0)
          ),
          new Loop(
            $start.getLine(), 
            new Nodes(new ArrayList<Node>(Arrays.asList(
              new Branch($start.getLine(),
                new Operation($start.getLine(), 
                  new Access(Identifier.Scope.LOCAL, new ArrayList(Arrays.asList(counterVariable))),
                  $expression.node,
                  "<"
                ),
                new Nodes(new ArrayList<Node>(Arrays.asList(
                  new Assign($start.getLine(), 
                    new ArrayList(Arrays.asList(counterVariable)),
                    new Operation(
                      new Access(Identifier.Scope.LOCAL, new ArrayList(Arrays.asList(counterVariable))),
                      new NumberLiteral($start.getLine(), 1),
                      "+"
                    )
                  ),
                  body
                ))),
                new Break($start.getLine(), null)
              )
            )))
          )
        ))
      );
    }
  ;

foreverLoop returns [Node node]
@init { Node body = null; }
  : FOREVER DO terminator?
    ( expressions                 { body = $expressions.nodes; }
    )?
    END                           { $node = new Loop($start.getLine(), body); }
  ;

breakStatement returns [Node node]
  : BREAK expression        { $node = new Break($start.getLine(), $expression.node); }
  | BREAK                   { $node = new Break($start.getLine(), null); }
  ;

returnStatement returns [Node node]
  : RETURN expression       { $node = new Return($start.getLine(), $expression.node); }
  | RETURN                  { $node = new Return($start.getLine(), null); }
  ;

timingStructure returns [Node node]
  : PAUSE                   { $node = new Pause($start.getLine()); }
  | STOP                    { $node = new Stop($start.getLine()); }
  | EXIT                    { $node = new Exit($start.getLine()); }
  ;

waitStatement returns [Node node]
@init {
  HashMap<Object, Node> value = new HashMap<Object, Node>(); 
  double index = 0; 
  Identifier type = new Identifier(Identifier.Scope.EXTERNAL, new ArrayList<String>(Arrays.asList("dog", "array")));
  Identifier call = new Identifier(Identifier.Scope.EXTERNAL, new ArrayList<String>(Arrays.asList("dog", "wait:")));
}
  : WAIT ON         
    head=expression        { value.put(index, $head.node); index++; }
    ( COMMA
      tail=expression      { value.put(index, $tail.node); index++; }
    )*                     {
                            $node = new Call(
                              $start.getLine(), 
                              false, 
                              call,
                              new ArrayList<Node>(Arrays.asList(new StructureLiteral($start.getLine(), type, value)))
                            );
                           }
  ;

onEachStatement returns [Node node]
@init {
  String argument = "";
  
  Nodes nodes = new Nodes();
  Node expression = null;
  String functionName = "@anonymous_" + java.util.UUID.randomUUID().toString();
  Identifier currentPackageIdentifer = new Identifier(Identifier.Scope.EXTERNAL, new ArrayList<String>(Arrays.asList("reflect", "current_package")));
  Identifier registerHandlerForFutureIdentifer = new Identifier(Identifier.Scope.EXTERNAL, new ArrayList<String>(Arrays.asList("future", "register_handler:for_future:")));
}
  : ON EACH         
    IDENTIFIER        { argument = $IDENTIFIER.text; }
                      { expression = new Access(Identifier.Scope.LOCAL, new ArrayList(Arrays.asList(argument + "s"))); }
    ( IN
      expression      { expression = $expression.node; }
    )?                { 
                        nodes.add(
                          new Call(
                            $start.getLine(),
                            false,
                            registerHandlerForFutureIdentifer,
                            new ArrayList<Node>(
                              Arrays.asList(
                                new Operation(
                                  $start.getLine(),
                                  new Access(
                                    $start.getLine(), 
                                    Identifier.Scope.LOCAL,
                                    new ArrayList<Object>(
                                      Arrays.asList(
                                        new Call(
                                          $start.getLine(),
                                          false,
                                          currentPackageIdentifer,
                                          new ArrayList<Node>()
                                        ),
                                        "name"
                                      )
                                    )
                                  ),
                                  new StringLiteral($start.getLine(), "." + functionName),
                                  "+"
                                ),
                                expression
                              )
                            )
                          )
                        ); 
                      }
    DO terminator?
    ( expressions     { nodes.add(
                          new FunctionDefinition(
                            $start.getLine(), 
                            functionName,
                            new ArrayList<String>(Arrays.asList(argument)),
                            $expressions.nodes
                          )
                        ); 
                      }
    )?
    END               { $node = nodes; }
  ;

onStatement returns [Node node]
@init { 
  ArrayList<HashMap> items = new ArrayList<HashMap>(); 
  HashMap item = new HashMap();
  Nodes nodes = new Nodes();

  HashMap<Object, Node> arrayMap = new HashMap<Object, Node>();
  double index = 0;

  String waitVariableName = "@wait" + dog.util.Helper.uniqueNumber();
  String arrayVariableName = "@wait_array" + dog.util.Helper.uniqueNumber();

  Identifier arrayId = new Identifier(Identifier.Scope.EXTERNAL, new ArrayList<String>(Arrays.asList("dog", "array")));
  Identifier callId = new Identifier(Identifier.Scope.EXTERNAL, new ArrayList<String>(Arrays.asList("dog", "wait:")));
  Identifier fromFutureId = new Identifier(Identifier.Scope.EXTERNAL, new ArrayList<String>(Arrays.asList("future", "is_value:from_future:")));

  Branch branch = null;
  Branch tempBranch = null;
  Branch branchPointer = null;
}
  : ON
    IDENTIFIER           { item.put("identifier", $IDENTIFIER.text); }  
                         { item.put("expression", new Access(Identifier.Scope.LOCAL, new ArrayList(Arrays.asList($IDENTIFIER.text + "s")))); }
                         { item.put("body", null); }
    ( IN
      expression         { item.put("expression", $expression.node); }
    )?
    DO terminator?
    ( expressions        { item.put("body", $expressions.nodes); }
    )?                   { items.add(item); }
    ( elseOnStatement    { items.add($elseOnStatement.item); }
    )*
    END                  {

      for(HashMap map : items) {
        arrayMap.put((Double)index, (Node)map.get("expression"));
        index++;
      }

      nodes.add(
        new Assign(
          $start.getLine(),
          new ArrayList<Object>(Arrays.asList(arrayVariableName)),
          new StructureLiteral($start.getLine(), arrayId, arrayMap)
        )
      );

      nodes.add(
        new Assign(
          $start.getLine(), 
          new ArrayList<Object>(Arrays.asList(waitVariableName)),
          new Call(
            $start.getLine(), 
            false, 
            callId,
            new ArrayList<Node>(Arrays.asList(
              new Access(
                $start.getLine(), 
                Identifier.Scope.LOCAL,
                new ArrayList<Object>(Arrays.asList(arrayVariableName))
              )
            ))
          )
        )
      );

      index = 0;
      for(HashMap map : items) {

        tempBranch = new Branch(
          new Call(
            $start.getLine(),
            false,
            fromFutureId,
            new ArrayList<Node>(
              Arrays.asList(
                new Access(Identifier.Scope.LOCAL, new ArrayList<Object>(Arrays.asList(waitVariableName))),
                new Access(Identifier.Scope.LOCAL, new ArrayList<Object>(Arrays.asList(arrayVariableName, (Double)index)))
            ))
          ),
          new Nodes(
            new ArrayList<Node>(Arrays.asList(
              new Assign(
                new ArrayList<Object>(Arrays.asList(map.get("identifier"))),
                new Access(Identifier.Scope.LOCAL, new ArrayList<Object>(Arrays.asList(waitVariableName)))
              ),
              (Nodes)map.get("body")
            ))
          ),
          null
        );
        
        if(branch == null) {
          branch = tempBranch;
          branchPointer = branch;
        } else {
          branchPointer.falseBranch = tempBranch;
          branchPointer = tempBranch;
        }

        index++;
      }

      nodes.add(branch);

      $node = nodes;
    }
  ;

elseOnStatement returns [HashMap item]
  : ELSE ON              { $item = new HashMap(); }
    IDENTIFIER           { $item.put("identifier", $IDENTIFIER.text); }
                         { $item.put("expression", new Access(Identifier.Scope.LOCAL, new ArrayList(Arrays.asList($IDENTIFIER.text + "s")))); }
                         { $item.put("body", null); }
    ( IN
      expression         { $item.put("expression", $expression.node); }
    )?
    DO terminator?
    ( expressions        { $item.put("body", $expressions.nodes); }
    )?
  ;

predicateStatement returns [Node node]
  : WHERE predicateExpression { $node = $predicateExpression.node; }
  ;

predicateExpression returns [StructureLiteral node]
  // predicateUnary        { $node = $predicateUnary.node; }
  : predicateBinary       { $node = $predicateBinary.node; }
  | predicatePrimary      { $node = $predicatePrimary.node; }
  ;

// TODO: Revive the unary operator in predicates
//predicateUnary returns [StructureLiteral node]
//  : NOT predicatePrimary { $node = dog.lang.compiler.Helper.invertPredicateConditions($predicatePrimary.node); }
//  ;

predicateBinary returns [StructureLiteral node]
@init { 
  String operator = ""; 
  HashMap<Object, Node> binaryExpressionMap = new HashMap<Object, Node>();
  HashMap<Object, Node> arrayMap = new HashMap<Object, Node>();

  Identifier predicateIdentifier = new Identifier(Identifier.Scope.EXTERNAL, new ArrayList(Arrays.asList("dog", "predicate")));
  Identifier arrayIdentifier = new Identifier(Identifier.Scope.EXTERNAL, new ArrayList(Arrays.asList("dog", "array")));

}
  : first=predicatePrimary     { arrayMap.put(0.0, $first.node); }
    ( AND                      { operator = "\$and"; }
    | OR                       { operator = "\$or"; }
    )                          
    second=predicateExpression { arrayMap.put(1.0, $second.node); }

    { binaryExpressionMap.put(operator, new StructureLiteral($start.getLine(), arrayIdentifier, arrayMap)); }
    { $node = new StructureLiteral($start.getLine(), predicateIdentifier, binaryExpressionMap); }
  ;

predicatePrimary returns [StructureLiteral node]
  : predicateParenthesis   { $node = $predicateParenthesis.node; }
  | predicateConditional   { $node = $predicateConditional.node; }
  ;

predicateParenthesis returns [StructureLiteral node]
  : OPEN_PAREN 
    predicateExpression 
    CLOSE_PAREN           { $node = $predicateExpression.node; }
  ;

predicateConditional returns [StructureLiteral node]
@init {
  StructureLiteral predicate = null;
  StructureLiteral pointer = null;
  StructureLiteral point;

  String operator = "";
  String last = "";
  String valueKey = "";

  int count;

  HashMap<Object, Node> elemMatch;
  HashMap<Object, Node> relationalMatch;

  HashMap<String, String> operatorMapping = new HashMap<String, String>();
  operatorMapping.put("!=", "\$ne");
  operatorMapping.put(">=", "\$gte");
  operatorMapping.put("<=", "\$lte");
  operatorMapping.put(">", "\$gt");
  operatorMapping.put("<", "\$lt");

  ArrayList path = new ArrayList();

  Identifier predicateIdentifier = new Identifier(Identifier.Scope.EXTERNAL, new ArrayList(Arrays.asList("dog", "predicate")));
  Identifier arrayIdentifier = new Identifier(Identifier.Scope.EXTERNAL, new ArrayList(Arrays.asList("dog", "array")));
}
  : predicatePath {
      path = $predicatePath.path;

      predicate = new StructureLiteral();
      pointer = predicate;

      count = 0;
      for (Object p : path) {
        String item = (String)p;
        count += 1;
        
        if(!(count < path.size() - 1)) {
          break;
        }
        
        point = new StructureLiteral($start.getLine());

        elemMatch = new HashMap<Object, Node>();
        elemMatch.put("key", new StringLiteral(item));
        elemMatch.put("value", point);

        pointer.value = new HashMap<Object, Node>();
        pointer.value.put("\$elemMatch", new StructureLiteral(elemMatch));
        
        pointer = point;
      }
    }
    relationalOperator {
      operator = operatorMapping.get($relationalOperator.text);
    }
    access {
      last = (String)path.get(path.size() - 1);

      if(last.equals("_id") && path.size() == 1) {
        $node = new StructureLiteral(predicateIdentifier);
        if(operator == null) {
          ((StructureLiteral)$node).value.put("_id", $access.node);
        } else {
          relationalMatch = new HashMap<Object, Node>();
          relationalMatch.put(operator, $access.node);

          ((StructureLiteral)$node).value.put("_id", new StructureLiteral(relationalMatch));
        }
      } else {
        if(last.equals("_id")) {
          valueKey = "value._id";
        } else {
          valueKey = "value.value";
        }

        if(operator == null) {
          elemMatch = new HashMap<Object, Node>();
          elemMatch.put("key", new StringLiteral(last));
          elemMatch.put(valueKey, $access.node);

          pointer.value = new HashMap<Object, Node>();
          pointer.value.put("\$elemMatch", new StructureLiteral(elemMatch));
        } else {
          relationalMatch = new HashMap<Object, Node>();
          relationalMatch.put(operator, $access.node);

          elemMatch = new HashMap<Object, Node>();
          elemMatch.put("key", new StringLiteral(last));
          elemMatch.put(valueKey, new StructureLiteral(relationalMatch));

          pointer.value = new HashMap<Object, Node>();
          pointer.value.put("\$elemMatch", new StructureLiteral(elemMatch));
        }

        $node = new StructureLiteral(predicateIdentifier);
        ((StructureLiteral)$node).value.put("value", predicate);
      }
    }
  ;

predicatePath returns [ArrayList path]
@init { ArrayList list = new ArrayList(); String item = ""; }
  : ( UNDERSCORE           { item = "_"; }
    )? 
    firstId=IDENTIFIER    { item += $firstId.text; }
                          { list.add(item); }
    ( DOT                 { item = ""; }
      ( UNDERSCORE        { item += "_"; }
      )?
      id=IDENTIFIER       { item += $id.text; }
                          { list.add(item); }
    )*                    { $path = list; }
  ;

packageDeclaration returns [Node node]
  : PACKAGE packageIdentifier  { $node = new dog.lang.nodes.Package($start.getLine(), $packageIdentifier.identifier); }
  ;

includeStatement returns [Node node]
  : INCLUDE packageIdentifier   { $node = new Include($start.getLine(), $packageIdentifier.identifier); }
  ;

literal returns [Node node]
  : NUMBER { $node = new NumberLiteral($start.getLine(), Double.parseDouble($text)); }
  | STRING { $node = new StringLiteral($start.getLine(), $text); }
  | TRUE   { $node = new TrueLiteral($start.getLine()); }
  | FALSE  { $node = new FalseLiteral($start.getLine()); }
  | NULL   { $node = new NullLiteral($start.getLine()); }
  | structure { $node = $structure.node; }
  | array     { $node = $array.node; }
  ;

structure returns [Node node]
@init { Identifier type = null;  HashMap<Object, Node> value = new HashMap<Object, Node>(); }
  : ( identifierPath          { type = $identifierPath.identifier; }
    )?
    OPEN_BRACE
    ( head=structureAssociation    { value.put($head.key, $head.node); }
    )?
    ( (COMMA | NEWLINE)+
      tail=structureAssociation    { value.put($tail.key, $tail.node); }
    )*
    (COMMA | NEWLINE)*
    CLOSE_BRACE                    { $node = new StructureLiteral($start.getLine(), type, value); }
  ;

structureAssociation returns [Object key, Node node]
  : ( IDENTIFIER { $key = $text; }
    | STRING     { $key = $text; }
    | NUMBER     { $key = Double.parseDouble($text); }
    )
    ASSIGN
    expression { $node = $expression.node; }
  ;

array returns [Node node]
@init { 
    HashMap<Object, Node> value = new HashMap<Object, Node>(); 
    double index = 0; 
    Identifier type = new Identifier(Identifier.Scope.EXTERNAL, new ArrayList<String>(Arrays.asList("dog", "array")));
}
  : OPEN_BRACKET
    ( head=expression       { value.put(index, $head.node); index++; }
    )?
    ( (COMMA | NEWLINE)+
      tail=expression       { value.put(index, $tail.node); index++; }
    )*
    (COMMA | NEWLINE)*
    CLOSE_BRACKET           { $node = new StructureLiteral($start.getLine(), type, value);  }
  ;


relationalOperator 
  : EQUAL
  | NOT_EQUAL
  | IDENTICAL
  | NOT_IDENTICAL
  | LESS_THAN_EQUAL
  | GREATER_THAN_EQUAL
  | LESS_THAN
  | GREATER_THAN
  ;

additiveOperator
  : PLUS 
  | MINUS
  ;

multiplicativeOperator
  : MULTIPLY
  | DIVIDE
  | MODULO
  ;

terminator
  : (NEWLINE | SEMICOLON)+
  | EOF
  ;

CASCADE:            'cascade';
EXTERNAL:           'external';
INTERNAL:           'internal';
LOCAL:              'local';

DEFINE:             'define';
COLLECTION:         'collection';
DO:		    		      'do';
END:                'end';
IF:                 'if';
ELSE:               'else';
WHILE:              'while';
REPEAT:             'repeat';
FOREVER:            'forever';
FOR:                'for';
ON:		  		        'on';
IN:                 'in';
EACH:               'each';

FROM:               'from';
WHERE:              'where';
SPAWN:              'spawn';

THEN:               'then';
TIMES:              'times';

RETURN:             'return';
BREAK:              'break';

INCLUDE: 	          'include';
PACKAGE:	          'package';

WAIT:	              'wait';
STOP:	              'stop';
PAUSE:	            'pause';
EXIT:	              'exit';

PRINT:         	    'print';

STRING      
@init{ StringBuilder buf = new StringBuilder(); }
  : '"' 
    ( escape=ESC                       {buf.append(getText());} 
    | normal=~('"'|'\\'|'\n'|'\r')     {buf.appendCodePoint($normal);} 
    )*
    '"'                                {setText(buf.toString());}
  | '\''
    ( normal=~('\'')                   {buf.appendCodePoint($normal);} 
    )*
    '\''                               {setText(buf.toString());}
  ;

NUMBER:             '-'? DIGIT+ ('.' DIGIT+)?;

TRUE:               'true';
FALSE:              'false';

NULL:               'null';

IDENTIFIER:         LOWER ID_CHAR*;
PARAMETER:          IDENTIFIER COLON;

COLON:              ':';
SEMICOLON:          ';';
DOT:                '.';
COMMA:              ',';
UNDERSCORE:         '_';

OPEN_BRACKET:       '[';
CLOSE_BRACKET:      ']';
OPEN_PAREN:         '(';
CLOSE_PAREN:        ')';
OPEN_BRACE:         '{';
CLOSE_BRACE:        '}';

ASSIGN:             '=';

EQUAL:              '==';
NOT_EQUAL:	        '!=';
IDENTICAL:          '===';
NOT_IDENTICAL:      '!==';
LESS_THAN_EQUAL:    '<=';
GREATER_THAN_EQUAL: '>=';
LESS_THAN:          '<';
GREATER_THAN:       '>';

PLUS:               '+';
MINUS:              '-';

MULTIPLY:           '*';
DIVIDE:             '/';
MODULO:             '%';

AND:                '&&' | 'and';
OR:                 '||' | 'or';
NOT:                '!' | 'not';

COMMENT:            '#' ~('\r' | '\n')* (NEWLINE | EOF) { $type = NEWLINE; };

NEWLINE:            '\r'? '\n';
WHITESPACE:         SPACE+ { $channel = HIDDEN; };

fragment ESC
  : '\\'
    ( 'n'    {setText("\n");}
    | 'r'    {setText("\r");}
    | 't'    {setText("\t");}
    | 'b'    {setText("\b");}
    | 'f'    {setText("\f");}
    | '"'    {setText("\"");}
    | '\''   {setText("\'");}
    | '/'    {setText("/");}
    | '\\'   {setText("\\");}
    | ('u')+ i=HEX_DIGIT j=HEX_DIGIT k=HEX_DIGIT l=HEX_DIGIT { setText(Character.toString((char)Integer.parseInt("" + $i.getText() + $j.getText() + $k.getText() + $l.getText(), 16))); }
    )
  ;

fragment LETTER:    LOWER | UPPER;
fragment ID_CHAR:   LETTER | DIGIT | '_';
fragment LOWER:     'a'..'z';
fragment UPPER:     'A'..'Z';
fragment DIGIT:     '0'..'9';
fragment HEX_DIGIT: ('0'..'9'|'a'..'f'|'A'..'F');
fragment SPACE:     ' ' | '\t';

