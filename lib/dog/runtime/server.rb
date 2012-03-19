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
    
    helpers do
      def layout(name)
        # Intentionally blank
      end
    end
    
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
    use Rack::Session::Cookie
    enable :logging  
    #enable :sessions
    enable :raise_errors
    
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
          
          @event = process_event(event)
          return unless @event
          
          reply_fiber = Fiber.new do
            reply = Fiber.yield
            if reply then
              body reply
            else
              # TODO
              body "Default content"
            end
          end
          
          for handler in @@handlers[location] do
            EM.next_tick do
              track = Track.new
              fiber = TrackFiber.new do
                ::Dog::Application::Handlers.send(handler, @event)
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
    
    def process_event(event)
      
      input = nil
      
      begin
        input = event.create_from_hash(params)
      rescue Exception => e
        input = nil
      end
      
      unless input
        status 400
        body "Invalid input"
        return nil
      else
        return input
      end
    end
    
    def notify_handlers(input)
      handlers = @@handlers[request.path]
      
      return unless input
      return unless handlers
      
      for handler in handlers do
        EM.next_tick do
          track = Track.new
          fiber = TrackFiber.new do
            ::Dog::Application::Handlers.send(handler, input)
          end
          track.fiber = fiber
          track.fiber.resume
        end
      end
    end
    
    
    
    
    class << self
      attr_accessor :global_track
      
      def boot
        port = Config.get('port')
        prefix = Config.get('dog_prefix')

        # TODO - I have to figure this out for production
        set :static, false
        set :public_folder, Proc.new { File.join(File.dirname($0), "views") }

        get_or_post prefix + 'meta' do
          body "Dog Meta Data."
        end      

        get_or_post prefix + 'account.signin' do
          @event = process_event(Account::SignIn)

          # Logic

          notify_handlers(input)
          reply
        end

        get_or_post prefix + 'account.signout' do
          @event = process_event(Account::SignOut)

          # Logic


          notify_handlers(input)
          reply
        end

        get_or_post prefix + 'account.create' do
          @event = process_event(Account::Create)

          # Logic
          people = Variable.named("dog.meta.people", Server.global_track)
          people.value ||= {}

          if people.value[event.email] then
            @event.success = false
            @event.errors ||= []
            @event.errors << "User name has already been taken."
          else
            
          end



          notify_handlers(input)
          reply 
        end

        get_or_post prefix + 'community.join' do
          @event = process_event(Community::Join)

          # Logic

          notify_handlers(input)
          reply
        end

        get_or_post prefix + 'community.leave' do
          @event = process_event(Community::Leave)

          # Logic

          notify_handlers(input)
          reply
        end

        Thin::Server.start '0.0.0.0', port, Server
      end
      
    end
    
    
    def reply
      if @event then
        status @event.status
        body @event.to_json
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