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
      # This default is important. It corresponds to the default package name (empty)
      self.startup_package = ""
      self.packages = {}
    end
    
    def finalize
      for name, package in self.packages do
        package.finalize
      end
    end
    
    def sign
      self.dog_version = VERSION::STRING
      self.dog_version_codename = VERSION::CODENAME
      self.time = Time.now
      self.signature = ""
      
      # TODO - Compute signature
    end
    
    def link(package)
      if package.class == Module then
        package = package.package
        name = package.name
        self.packages[name] = package
      else
        name = package.name
        self.packages[name] = package
      end
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
        hash["packages"][name] = package.to_hash
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
      new_packages = {}

      for name, package in packages do
        new_packages[name] = ::Dog::Package.from_hash(package)
      end

      bundle.packages = new_packages

      return bundle
    end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
=begin TODO - Remove these
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
      symbol = self.packages[package]["symbols"][symbol] rescue nil
      
      if symbol then
        return symbol.clone
      else
        return nil
      end
    end

    def node_at_path(path, package = nil)
      package ||= Runtime.bundle.startup_package
      
      node = self.packages[package]["code"]

      for index in path do
        node = node[index]
      end

      return node
    end

    def node_for_symbol(symbol, package = nil)
      path = path_for_symbol(symbol, package)
      node = node_at_path(path, package)
      return node
    end
=end
    
    
    
    
    
    
    
    
    
    
    
    
    
  end
  
end

