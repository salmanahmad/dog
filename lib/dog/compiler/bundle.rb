#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class Bundle
    
    attr_accessor :dog_version
    attr_accessor :dog_version_codename
    
    attr_accessor :time
    attr_accessor :signature
    
    attr_accessor :startup_package
    attr_accessor :packages
    
    def initialize
      # TODO - This default is important. It corresponds to the default package name (empty)
      self.startup_package = ""
      self.packages = {}
    end
    
    def sign
      self.dog_version = VERSION::STRING
      self.dog_version_codename = VERSION::CODENAME
      self.time = Time.now
      self.signature = ""
      
      # TODO - Compute signature
    end
    
    def link(package)
      # TODO - Figure out what the difference is between Bundle#link and Compiler#link
      # Perhaps this is a dynamic link and compiler is static?
      if package.class == Module then
        if package.respond_to?(:symbols) && package.respond_to?(:name) then
          symbols = package.symbols
          name = package.name
          
          for symbol in symbols do
            self.add_symbol_to_package(symbol[0], symbol[1], name)
          end
          
          self.packages[name]["name"] = name
          self.packages[name]["native_code"] = package
        end
      else
        # TODO - Perhaps add a package type just like Bundle
      end
      
    end

    def read_package(package)
      name = package
      package = self.packages[package]
      
      return ::Dog::Value.null_value unless package
      
      value = ::Dog::Value.new("package", {})
      
      for symbol, path in package["symbols"] do
        node = node_at_path(path, name)
        value.value["s:#{symbol}"] = node.read_definition rescue ::Dog::Value.null_value
      end
      
      return value
    end

    def contains_symbol_in_package?(symbol, package)
      self.packages[package]["symbols"].include?(symbol) rescue false
    end

    def add_symbol_to_package(symbol, path, package)
      self.packages[package] ||= {}
      self.packages[package]["symbols"] ||= {}
      self.packages[package]["symbols"][symbol] = path
    end

    def path_for_symbol(symbol, package = nil)
      package ||= Runtime.bundle.startup_package
      symbol = self.packages[package]["symbols"][symbol]
      
      if symbol then
        return symbol.clone
      else
        return nil
      end
    end

    def node_at_path(path, package = nil)
      package ||= Runtime.bundle.startup_package

      if path.kind_of? String
        # If the path is a string and not an array, it means that it is a native code call
        node = ::Dog::Nodes::NativeCode.new
        node.module = self.packages[package]["native_code"]
        node.method = path
        return node
      else
        node = self.packages[package]["code"]

        for index in path do
          node = node[index]
        end

        return node
      end
    end

    def node_for_symbol(symbol, package = nil)
      path = path_for_symbol(symbol, package)
      node = node_at_path(path, package)
      return node
    end

    def to_hash
      hash = {
        "dog_version" => self.dog_version,
        "dog_version_codename" => self.dog_version_codename,
        "time" => self.time,
        "signature" => self.signature,
        "startup_package" => self.startup_package,
        "packages" => {}
      }
      
      for name, package in self.packages do
        hash["packages"][name] = package
        hash["packages"][name]["code"] = package["code"].to_hash
      end
      
      return hash
    end
    
    def self.from_hash(hash)
      bundle = self.new
      bundle.dog_version = hash["dog_version"]
      bundle.dog_version_codename = hash["dog_version_codename"]
      bundle.time = hash["time"]
      bundle.signature = hash["signature"]
      bundle.startup_package = hash["startup_package"]
      bundle.packages = hash["packages"]
      
      packages = bundle.packages
      for name, package in packages do
        # I need the second call here so that I can initialize the parent pointers in the tree.
        # I may want to incorporate this into from_hash at some point.

        ast = package["code"]
        ast = Nodes::Node.from_hash(ast)
        ast.compute_paths_of_descendants
        
        package["code"] = ast
      end
      
      return bundle
    end
    
  end
  
end

