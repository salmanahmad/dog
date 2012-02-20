#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class Server < Sinatra::Base
    register Sinatra::Async
    
    enable  :sessions, :logging
    
    @@listeners = false
    
    def self.listeners?
      @@listeners
    end
    
    def self.listeners=(flag)
      @@listeners = flag
    end
  end
  
end