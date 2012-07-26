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
    
    attr_accessor :packages
    
    def initialize
      self.packages = {}
    end
    
    def sign
      self.dog_version = VERSION::STRING
      self.dog_version_codename = VERSION::CODENAME
      self.time = Time.now
      self.signature = ""
      
      # TODO - Compute signature
    end
    
    def contains_symbol_in_package?(symbol, package)
      self.packages[package]["symbols"].include?(symbol) rescue false
    end
    
    def add_symbol_to_package(symbol, path, package)
      self.packages[package] ||= {}
      self.packages[package]["symbols"] ||= {}
      self.packages[package]["symbols"][symbol] = path
    end
    
    def to_hash
      hash = {
        "dog_version" => self.dog_version,
        "dog_version_codename" => self.dog_version_codename,
        "time" => self.time,
        "signature" => self.signature,
        "packages" => {}
      }
      
      for name, package in self.packages do
        hash["packages"][name] = package
        hash["packages"][name]["code"] = package["code"].to_hash
      end
      
      return hash
    end
    
    def from_hash
      
    end
    
  end
  
end

