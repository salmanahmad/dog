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
    @@variables = {}
    
    def self.register(variable)
      path = variable.track.name + "/" + variable.name
      puts "Registering: #{path}"
      @@variables[path] = variable
    end
    
    def self.listeners?
      @@listeners
    end
    
    def self.listeners=(flag)
      @@listeners = flag
    end
    
    apost '/track' do
      
      path = params["path"]
      params.delete("path")  
      variable = @@variables[path]
      
      # Validate variable
      if variable.nil? then
        response.status = 404
        body
      else
        variable.push_value(params)
        
        context = RequestContext.new
        variable.notify_dependencies context
        
        EM.next_tick do
          body context.body
          if variable.complete? then
            @@variables.delete(path)
          end
        end
        
      end
      
    end
    
  end
  
end