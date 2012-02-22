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
    use Rack::Session::Cookie
    register Sinatra::Async
    
    #enable :sessions
    enable :logging
    
    @@listeners = false
    @@variables = {}
    
    def self.reset
      @@variables = {}
    end
    
    def self.register(variable, callback_path)
      @@variables[callback_path] = variable
    end
    
    def self.listeners?
      @@listeners
    end
    
    def self.listeners=(flag)
      @@listeners = flag
    end
    
    get '/logout' do
      session['authenticate_redirect'] = nil
      session['dormouse_access_token'] = nil
      redirect '/'
    end
    
    get '/authenticate' do
      @error = nil
      
      # TODO - Move away from HTTParty
      
      access_token = HTTParty.get(Environment.dormouse_access_token_url(params[:code]))
      if access_token.success? then
        session['dormouse_access_token'] = access_token.parsed_response
        url = $authenticate_redirects[session[:session_id]]
        redirect url
      else
        "Could not verify your user account."
      end
    end
    
    
    apost '/action' do
      
      path = params["DogAction"]
      params.delete("DogAction")  
      variable = @@variables[path]
      
      # TODO - Handle authentication here...
      
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