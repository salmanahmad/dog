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
    
    # Automatically parse JSON
    
    before do
      if request.media_type == 'application/json' then
        parameters = nil
        begin
          parameters = JSON.parse(request.body)
        rescue
          parameters = {}
        end
        
        params.merge!(parameters)
      end
    end
    
    # CORS Supports
    # TODO - Support JSONP
    # TODO - Host dog.js from Dog to avoid any XSS
    
    after do
      response['Access-Control-Allow-Origin'] = '*'
      response['Access-Control-Allow-Methods'] = 'POST, PUT, GET, DELETE, OPTIONS'
      response['Access-Control-Max-Age'] = "1728000"
    end

    options '/*' do
      response['Access-Control-Allow-Origin'] = '*'
      response['Access-Control-Allow-Methods'] = 'POST, PUT, GET, DELETE, OPTIONS'
      response['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version'
      response['Access-Control-Max-Age'] = '1728000'
      response['Content-Type'] = 'text/plain'
      return ''
    end
    
    helpers do
      def layout(name)
        # Intentionally blank. Used by our template system.
      end
    end
    
    def self.get_or_post(path, opts={}, &block)
      get(path, opts, &block)
      post(path, opts, &block)
    end
    
    def self.aget_or_post(path, opts={}, &block)
      aget(path, opts, &block)
      apost(path, opts, &block)
    end
    
    
    # If I remember correctly, I was having problems with
    # sinatra async and the default cookie-based sessions
    # I used this to address some of the concerns.
    register Sinatra::Async
    
    # TODO - Set the secret here!
    use Rack::Session::Cookie
    enable :logging  
    #enable :sessions
    enable :raise_errors
    
    def self.expose_variable(variable, options = {})
      @@listeners = true
      # TODO
    end
    
    def self.expose_community(community, options = {})
      @@listeners = true
      # TODO
    end
    
    def self.expose_profile_property(property, options = {})
      @@listeners = true
      # TODO
    end
    
    @@handlers = {}
    
    def self.listen(options = {})
      @@listeners = true
      
      if options[:handler].nil? || options[:event].nil? then
        raise "You must provide a handler an event to a listener."
      end
      
      eligibility = options[:eligibility]
      variable_name = options[:variable_name]
      handler = options[:handler] 
      event = options[:event]
      location = options[:at]
      
      if event.ancestors.include? SystemEvent then
        location = Config.get('dog_prefix') + event.identifier
        @@handlers[location] ||= []
        @@handlers[location].push(handler)
      elsif
        # TODO - Validate that the location is not part of the prefix
        if location[0] != '/' then
          location = '/' + location   
        end
        
        @@handlers[location] ||= [] 
        @@handlers[location].push(handler)
         
        self.aget_or_post location do
          
          @event = process_incoming_event(event) rescue return
          
          reply_fiber = Fiber.new do
            reply = Fiber.yield
            begin
              if reply then
                @event.assign(reply)
                @event.success = true if @event.success.nil?
              end
            rescue Exception => e
              # TODO - Reraise error for Dog?
              @event.status = false
            end
            
            process_outgoing_event
          end
          
          for handler in @@handlers[location] do
            EM.next_tick do
              track = Track.create(:parent_id => Track.root.id)
              fiber = TrackFiber.new do
                variable = Variable.named(variable_name)
                variable.value = @event
                variable.save
                h = handler.new
                h.run
              end
              track.context[:reply_fiber] = reply_fiber
              track.fiber = fiber
              track.fiber.resume
            end
          end
          
          reply_fiber.resume
        end        
      end
    end
    
    def process_incoming_event(event)
      input = nil
      input = event.import(params) rescue nil
      
      if input.nil?
        # TODO - Better error reporting...
        status 400
        body "Invalid event"
        raise
      end
      
      return input
    end
    
    def process_outgoing_event
      # TODO - Figure out how to update sucecess if the export fails...
      content_type 'application/json'
      
      output = @event.export
      if output.nil? then
        # Raise Error for Dog?
        @event.success = false
        output = {}
      end
      
      if @event.success
        status 200
      else
        status 403
      end
      
      body output.to_json
      
    end
    
    def notify_handlers
      handlers = @@handlers[request.path]
      
      return unless @event
      return unless handlers
      
      for handler in handlers do
        EM.next_tick do
          track = Track.create(:parent_id => Track.root.id)
          fiber = TrackFiber.new do
            ::Dog::Application::Handlers.send(handler, @event)
          end
          track.fiber = fiber
          track.fiber.resume
        end
      end
    end
    
    class << self
      attr_accessor :global_track
      
      def boot
        prefix = Config.get('dog_prefix')

        # TODO - I have to figure this out for production
        set :static, false
        set :public_folder, Proc.new { File.join(File.dirname($0), "views") }
        
        get_or_post prefix + 'meta' do
          body "Dog Meta Data."
        end      
        
        get_or_post prefix + 'account.status' do
          @event = process_incoming_event(Account::LoginStatus) rescue return
          
          if session[:current_user]
            @event.success = true
            @event.logged_in = true
          else
            @event.success = true
            @event.logged_in = false
          end
          
          notify_handlers
          process_outgoing_event
        end
        
        get_or_post prefix + 'account.login' do
          @event = process_incoming_event(Account::Login) rescue return
          
          person = Person.find_by_email(@email.email)
          if person && person.password == Digest::SHA1.hexdigest(@event.password)
            @event.success = true
            session[:current_user] = person.id
          else
            @event.success = false
            @event.errors ||= []
            @event.errors << "Wrong Username/Email and password combination."
          end
          
          notify_handlers
          process_outgoing_event
        end

        get_or_post prefix + 'account.logout' do
          @event = process_incoming_event(Account::Logout) rescue return
          
          session.clear
          @event.success = true

          notify_handlers
          process_outgoing_event
        end
        
        get_or_post prefix + 'account.create' do
          @event = process_incoming_event(Account::Create) rescue return
          
          @event.password ||= ""
          @event.confirm ||= ""
          
          person = Person.find_by_email(@event.email)
          
          if person then
            @event.success = false
            @event.errors ||= []
            @event.errors << "User name has already been taken."
          else
            if @event.password != @event.confirm then
              @event.success = false
              @event.errors ||= []
              @event.errors << "Password and Confirmation does not match."
            else
              @event.success = true
              
              person = Person.new
              person.email = @event.email
              person.password = Digest::SHA1.hexdigest @event.password
              person.save
                
              session[:current_user] = person.id
              notify_handlers
            end
          end
          
          process_outgoing_event
        end
        
        get_or_post prefix + 'community.join' do
          @event = process_incoming_event(Community::Join) rescue return
          
          # Logic
          
          notify_handlers
          process_outgoing_event
        end

        get_or_post prefix + 'community.leave' do
          @event = process_incoming_event(Community::Leave) rescue return
          
          # Logic
          
          notify_handlers
          process_outgoing_event
        end
        
        
        get '*' do
          path = params[:splat].first
          path = "/index.html" if path == "/"
          path = settings.public_folder + path

          if File.exists? path then
            if File.extname(path) == ".html" then
              line = File.open(path, &:readline)
              match = line.match /^\s*<%=\s*layout\s+"(.+)"\s*%>\s*$/
              if match then
                template = settings.public_folder + match[1]
                template_content = File.open(template, &:read)
                path_content = File.open(path, &:read)

                erb path_content, :layout => template_content, :views => '/'
              else
                send_file path
              end
            else
              send_file path
            end
          else
            404
          end
        end
        
        # This is very important. Do not remove this or testing will not work
        return self
      end
      
      def run
        # TODO - You must call boot first. Right now we are not because of testing.
        Thin::Server.start '0.0.0.0', Config.get('port'), Server
      end
      
    end
    

    
    
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
        session['dormouse_user'] = 
        
        url = $authenticate_redirects[session[:session_id]]
        $authenticate_redirects.delete [session[:session_id]]
        redirect url
      else
        "Could not verify your user account."
      end
    end
    
    
    post '/action' do
      
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