#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  module VERSION
    MAJOR    = 0
    MINOR    = 3
    TINY     = 0
    
    STRING   = [MAJOR, MINOR, TINY].join('.').freeze
    
    CODENAME = "Emerald Hill".freeze
  end
  
  def self.win?
    RUBY_PLATFORM =~ /mswin|mingw/
  end
  
  def self.linux?
    RUBY_PLATFORM =~ /linux/
  end
  
  def self.ruby_18?
    RUBY_VERSION =~ /^1\.8/
  end
end
