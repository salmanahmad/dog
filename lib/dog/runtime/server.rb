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
      
      def verify_current_user(message = "You need to be logged in when performing this operation")
        unless session[:current_user]
          @event.success = false
          @event.errors = [message]
          process_outgoing_event
          return false
        end
        
        return true        
      end
      
      def verify_not_current_user(message = "You cannot be logged in when performing this operation.")
        if session[:current_user]
          @event.success = false
          @event.errors = [message]
          process_outgoing_event
          return false
        end
        
        return true
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
    #enable :raise_errors
    
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
      
      
      if event.ancestors.include? ::Dog::SystemEvents::SystemEvent then
        location = Config.get('dog_prefix') + event.identifier
        @@handlers[location] ||= []
        @@handlers[location].push(handler)
      else
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
          
          # TODO - Consolidate this logic with notify_handlers below for API events
          
          for handler in @@handlers[location] do
            EM.next_tick do
              track = Track.create(:parent_id => Track.root.id)
              fiber = TrackFiber.new do
                handler.run
                ::Dog::reply nil
              end
              
              variable = Variable.named(handler.variable_name, track)
              variable.person_id = session[:current_user]
              variable.value = @event
              variable.save
              
              fiber.context[:reply_fiber] = reply_fiber
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
      begin
        input = event.import(params) 
      rescue => e
        
      end
      
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
      
      if @event.success == false
        status 403
      else
        status 200
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
            handler.run
          end
          
          variable = Variable.create(handler.variable_name, track)
          variable.person_id = session[:current_user]
          variable.value = @event
          variable.save
          
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
          @event = process_incoming_event(::Dog::SystemEvents::Account::LoginStatus) rescue return
          
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
          @event = process_incoming_event(::Dog::SystemEvents::Account::Login) rescue return
          
          person = Person.find_by_email(@event.email)
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
          @event = process_incoming_event(::Dog::SystemEvents::Account::Logout) rescue return
          
          session.clear
          @event.success = true

          notify_handlers
          process_outgoing_event
        end
        
        get_or_post prefix + 'account.create' do
          @event = process_incoming_event(::Dog::SystemEvents::Account::Create) rescue return
          
          return unless verify_not_current_user("You cannot be logged in when creating a new account.")
          
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
              person.join_community_named(Config.get("default_community"))
              person.save
                
              session[:current_user] = person.id
              notify_handlers
            end
          end
          
          process_outgoing_event
        end
        
        # TODO - Privacy considerations need to go here...
        
        get_or_post prefix + 'people.search' do
          @event = process_incoming_event(::Dog::SystemEvents::People::Search) rescue return
          
          @event.results = Person.search(@event.query)
          @event.success = true
          
          notify_handlers
          process_outgoing_event
        end
        
        get_or_post prefix + 'people.view' do
          @event = process_incoming_event(::Dog::SystemEvents::People::View) rescue return
          
          person = Person.find_by_id(@event.id)
          if person then
            @event.person = person.to_hash_for_event
            @event.success = true
          else
            @event.success = false
            @event.errors ||= []
            @event.errors << "Could not find the user with that identifier."
          end
          
          notify_handlers
          process_outgoing_event
        end
        
        get_or_post prefix + 'profile.view' do
          @event = process_incoming_event(::Dog::SystemEvents::Profile::View) rescue return
          
          return unless verify_current_user("You have to be logged in to view your profile.")
          
          person = Person.find_by_id(session[:current_user])
          @event.value = person.to_hash_for_event
          @event.success = true
          
          notify_handlers
          process_outgoing_event
        end
        
        get_or_post prefix + 'profile.write' do
          @event = process_incoming_event(::Dog::SystemEvents::Profile::Write) rescue return
          
          return unless verify_current_user("You have to be logged in to write to your profile.")
          
          person = Person.find_by_id(session[:current_user])
          success = person.write_profile(@event.value)
          person.save if success
          @event.success = success
          
          
          notify_handlers
          process_outgoing_event
        end
        
        get_or_post prefix + 'profile.update' do
          @event = process_incoming_event(::Dog::SystemEvents::Profile::Update) rescue return
          
          return unless verify_current_user("You have to be logged in to update your profile.")
          
          person = Person.find_by_id(session[:current_user])
          success = person.update_profile(@event.value)
          person.save if success
          @event.success = success
          
          notify_handlers
          process_outgoing_event
        end
        
        get_or_post prefix + 'profile.push' do
          @event = process_incoming_event(::Dog::SystemEvents::Profile::Push) rescue return
          
          return unless verify_current_user("You have to be logged in to update your profile.")
          
          person = Person.find_by_id(session[:current_user])
          success = person.push_profile(@event.value)
          person.save if success
          @event.success = success
          
          notify_handlers
          process_outgoing_event
        end
        
        get_or_post prefix + 'profile.pull' do
          @event = process_incoming_event(::Dog::SystemEvents::Profile::Pull) rescue return
          
          return unless verify_current_user("You have to be logged in to update your profile.")
          
          person = Person.find_by_id(session[:current_user])
          success = person.pull_profile(@event.value)
          person.save if success
          @event.success = success
          
          notify_handlers
          process_outgoing_event
        end
        
        get_or_post prefix + 'community.join' do
          @event = process_incoming_event(::Dog::SystemEvents::Community::Join) rescue return
          
          return unless verify_current_user("You have to be logged in to join a community.")
          
          person = Person.find_by_id(session[:current_user])
          success = person.join_community_named(@event.name)
          @event.success = success
          
          notify_handlers
          process_outgoing_event
        end

        get_or_post prefix + 'community.leave' do
          @event = process_incoming_event(::Dog::SystemEvents::Community::Leave) rescue return
          
          return unless verify_current_user("You have to be logged in to leave a community.")
          
          person = Person.find_by_id(session[:current_user])
          success = person.leave_community_named(@event.name)
          @event.success = success
          
          notify_handlers
          process_outgoing_event
        end
        
        get_or_post prefix + 'tasks.view' do
          @event = process_incoming_event(::Dog::SystemEvents::Tasks::View) rescue return
          
          return unless verify_current_user("You have to be logged in to view tasks.")
          
          current_user = Person.find_by_id(session[:current_user])
          task = RoutedTask.find_by_id(@event.id)
          
          if task.route_to_person? current_user then
            @event.success = true
            @event.task = task.to_hash_for_event
            notify_handlers
          else
            @event.success = false
            @event.errors ||= []
            @event.errors << "You are not eligible for this task."
          end
          
          process_outgoing_event
        end
        
        get_or_post prefix + 'tasks.list' do
          @event = process_incoming_event(::Dog::SystemEvents::Tasks::List) rescue return
          
          return unless verify_current_user("You have to be logged in to view tasks.")
          
          # TODO Task options
          current_user = Person.find_by_id(session[:current_user])
          @event.tasks = RoutedTask.for_person(current_user, {:completed => @event.completed, :after_task_id => @event.after_task_id, :type => @event.type})
          @event.success = true
          
          notify_handlers
          process_outgoing_event
        end
        
        get_or_post prefix + 'messages.view' do
          @event = process_incoming_event(::Dog::SystemEvents::Messages::View) rescue return
          
          return unless verify_current_user("You have to be logged in to view messages.")
          
          current_user = Person.find_by_id(session[:current_user])
          message = RoutedMessage.find_by_id(@event.id)
          
          if message.route_to_person? current_user then
            @event.success = true
            @event.message = message.to_hash_for_event
            notify_handlers
          else
            @event.success = false
            @event.errors ||= []
            @event.errors << "You are not eligible for this message."
          end
          
          process_outgoing_event
        end
        
        get_or_post prefix + 'messages.list' do
          @event = process_incoming_event(::Dog::SystemEvents::Messages::List) rescue return
          
          return unless verify_current_user("You have to be logged in to view messages.")
          
          current_user = Person.find_by_id(session[:current_user])
          @event.messages = RoutedMessage.for_person(current_user)
          @event.success = true
          
          notify_handlers
          process_outgoing_event
        end
        
        get_or_post prefix + 'tasks.respond' do
          @event = process_incoming_event(::Dog::SystemEvents::Tasks::Respond) rescue return
          
          return unless verify_current_user("You have to be logged in to respond to tasks.")
          
          current_user = Person.find_by_id(session[:current_user])
          current_task = RoutedTask.find_by_id(@event.id)
          
          if current_task.route_to_person?(current_user) then
            current_task.process_response(@event.response, current_user)
            current_task.save
            Variable.notify_handlers_for_task(current_task)
            @event.success = true
          else
            
            @event.success = false
            @event.errors ||= []
            @event.errors << "You are not eligible for this task"
            return
          end          
          
          process_outgoing_event
        end
        
        get_or_post prefix + 'workflows.list' do
          @event = process_incoming_event(::Dog::SystemEvents::Workflows::List) rescue return
          
          return unless verify_current_user("You have to be logged in to view workflows.")
          
          current_user = Person.find_by_id(session[:current_user])
          @event.workflows = Workflow.for_person(current_user)
          @event.success = true
          
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
 
  end
  
end