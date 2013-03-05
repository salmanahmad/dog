package dog.packages.dog;

import dog.lang.Value;
import dog.lang.StringValue;
import dog.lang.StructureValue;
import dog.lang.Function;
import dog.lang.Signal;
import dog.lang.StackFrame;
import dog.lang.annotation.Symbol;
import dog.lang.Resolver;
import dog.lang.parser.Parser;
import dog.lang.compiler.Compiler;
import dog.lang.compiler.Identifier;
import dog.lang.nodes.Node;
import dog.lang.nodes.Nodes;
import dog.lang.nodes.Assign;
import dog.lang.nodes.Call;
import dog.lang.nodes.FunctionDefinition;


import java.util.ArrayList;
import java.util.Arrays;

@Symbol("dog.eval:")
public class Eval extends Function {

	public int getVariableCount() {
		return 1;
	}

	public int getRegisterCount() {
		return 1;
	}

	public Signal resume(StackFrame frame) {
		switch(frame.programCounter) {
		case 0:
			if(!(frame.variables[0] instanceof StringValue)) {
				throw new RuntimeException("dog.eval: expects a string");
			}
			String[] inheritedVars = this.inheritedVariableNames(frame);
			String source = ((StringValue)frame.variables[0]).value;
			StackFrame invocation = new StackFrame("null.eval_wrapper", 
												   this.compileAndLink(frame, source, inheritedVars), 
												   this.inheritedVariables(frame));
			frame.returnRegister = 0;
			frame.programCounter++;
			return new Signal(Signal.Type.INVOKE, invocation);
		default:
			StructureValue output = (StructureValue)frame.registers[0];
			frame.registers[0] = output.get("eval_result_");
			output.value.remove("eval_result_");
			this.copyVariablesToParent(frame, output);
			return new Signal(Signal.Type.RETURN);
		}
	}

	private void copyVariablesToParent(StackFrame frame, StructureValue output) {
		StackFrame parent = frame.parentStackFrame();
		int numVariables = parent.variables.length;

		if (numVariables < output.value.size()){
			// No need to actually copy the old values, because we're
			// about to overwrite them anyway.
			parent.variables = new Value[output.value.size()];
		}

		for (Object okey : output.value.keySet()){
			String key = (String)okey;
			Integer index = parent.variableTable.get(key);
			if (index == null){
				index = numVariables++;
				parent.variableTable.put(key, index);
			} 
			parent.variables[index] = output.get(key);
		}
	}

	private void link(Resolver resolver, Compiler compiler){
		Resolver parent = resolver.getParentResolver();
		ArrayList<dog.lang.compiler.Symbol> symbols = compiler.getSymbols();

		for(dog.lang.compiler.Symbol symbol : symbols) {
			symbol.compile();
		}

		for(dog.lang.compiler.Symbol symbol : symbols) {
			if (parent==null || symbol.name.equals("null.eval_wrapper")){
				// Our main entrypoint is linked in our temporary
				// resolver.
				resolver.linkBytecode(symbol.bytecode);
			} else {
				// Any other new symbols are linked to the main
				// resolver.
				parent.linkBytecode(symbol.bytecode);
			}
		}
	}

	private Resolver compileAndLink(StackFrame frame, String source, String[] inheritedVars) {
		Resolver resolver = new Resolver(frame.getRuntime().getResolver());
		Compiler compiler = new Compiler(resolver);
		Parser parser = new Parser();
		Nodes ast = parser.parse(source);
		ast = this.mangleAst(ast, inheritedVars);
		compiler.addCompilationUnit(ast, "<eval>");
		this.link(resolver, compiler);
		return resolver;
	}

	private String[] inheritedVariableNames(StackFrame frame){
		StackFrame parent = frame.parentStackFrame();
		if (parent == null){
			return new String[0];
		}
		String[] variableNames = new String[parent.variables.length];
		for (String variable : parent.variableTable.keySet()){
			variableNames[parent.variableTable.get(variable)] = variable;
		}
		return variableNames;
	}

	private Value[] inheritedVariables(StackFrame frame){
		StackFrame parent = frame.parentStackFrame();
		if (parent == null){
			return new Value[0];
		}
		Value[] variables = new Value[parent.variables.length];
		for (int index=0; index < parent.variables.length; index++){
			variables[index] = parent.variables[index];
		}
		return variables;
	}

	private Nodes mangleAst(Nodes ast, String[] inheritedVars){
		Nodes tmp;
		
		// FunctionDefinitions have no return value, so we append
		// "null" so there's something to return.
		if (ast.children().get(ast.children().size()-1) instanceof FunctionDefinition){
			ast.add((new Parser()).parse("null"));
		}

		// Wrap the user's AST in an assignment so we can capture the
		// final value.
		tmp = new Nodes();
		ArrayList<Object> path = new ArrayList<Object>();
		path.add("eval_result_");
		tmp.add(new Assign(path, ast));
		ast = tmp;

		// Then append a call to dog.locals, so that we return both
		// the user's final value and the (possibly mutated) shadowed
		// local variables.
		ast.add(this.invokeLocals());

		// Finally wrap it all into a function so we can easily invoke
		// it.
		tmp = new Nodes();
		tmp.add(new FunctionDefinition("eval_wrapper", new ArrayList<String>(Arrays.asList(inheritedVars)), ast));
		ast = tmp;
		return ast;
	}

	private Nodes invokeLocals(){
		Nodes output = new Nodes();
		Identifier name = new Identifier();
		name.path.add("dog");
		name.path.add("locals");
		output.add(new Call(false, name, new ArrayList<Node>()));
		return output;
	}
}

