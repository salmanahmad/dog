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

package dog.lang.nodes;

import dog.lang.compiler.Symbol;
import dog.lang.compiler.Compiler;

import java.util.ArrayList;

public abstract class Node {
	public int line;

    public String filePath;
	public ArrayList<String> packageName;
	public ArrayList<ArrayList<String>> includedPackages;
	public ArrayList<ArrayList<String>> loadedPackages;

	public Node parent;
	
	public Node() {
		this.line = -1;
	}

	public Node(int line) {
		this.line = line;
	}

	public void setParentOfChild(Node child) {
		if(child != null) {
			child.parent = this;
		}
	}

	public ArrayList<String> getPackageName() {
		ArrayList<String> packageName = null;

		for(Node child : this.children()) {
			ArrayList<String> temporaryPackageName = child.getPackageName();
			if(temporaryPackageName != null) {
				packageName = temporaryPackageName;
			}
		}

		return packageName;
	}

	public ArrayList<ArrayList<String>> getIncludedPackages() {
		ArrayList<ArrayList<String>> includedPackages = new ArrayList<ArrayList<String>>();

		for(Node child : this.children()) {
			ArrayList<ArrayList<String>> temp = child.getIncludedPackages();
			includedPackages.addAll(temp);
		}

		return includedPackages;
	}

	public ArrayList<ArrayList<String>> getLoadedPackages() {
		return null;
	}

	public void scaffold(Compiler compiler) {
		for(Node child : this.children()) {
			child.scaffold(compiler);
		}
	}

	public abstract void compile(Symbol symbol);
	public abstract ArrayList<Node> children();
}


