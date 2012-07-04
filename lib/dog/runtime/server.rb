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
        @output = {}
        
        unless session[:current_user]
          @output["success"] = false
          @output["errors"] = [message]
          body @output.to_json
          return false
        end
        
        return true        
      end
      
      def verify_not_current_user(message = "You cannot be logged in when performing this operation.")
        @output = {}
        
        if session[:current_user]
          @output["success"] = false
          @output["errors"] = [message]
          body @output.to_json
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
    
    class << self
      
      def initialize
        return if @initialized
        @initialized = true
        
        prefix = Config.get('dog_prefix')
        
        # TODO - I have to figure this out for production
        set :static, false
        set :public_folder, Proc.new { File.join(File.dirname(Runtime.bite_code_filename), "views") }
        
        self.initialize_vet
        
        get prefix + '/account/status' do
          @output = {}
          
          if session[:current_user]
            @output["success"] = true
            @output["logged_in"] = true
          else
            @output["success"] = true
            @output["logged_in"] = false
          end
          
          @output.to_json
        end
        
        get prefix + '/account/login' do
          @output = {}
          
          person = Person.find_by_email(params["email"])
          if person && person.password == Digest::SHA1.hexdigest(params["password"])
            @output["success"] = true
            session[:current_user] = person.id
          else
            @output["success"] = false
            @output["errors"] ||= []
            @output["errors"] << "Wrong Username/Email and password combination."
          end
          
          @output.to_json
        end

        get prefix + '/account/logout' do
          @output = {}
          
          session.clear
          @output["success"] = true
          
          @output.to_json
        end
        
        post prefix + '/account/create' do
          return unless verify_not_current_user("You cannot be logged in when creating a new account.")
          
          @output = {}
          
          params["password"] ||= ""
          params["confirm"] ||= ""
          
          person = Person.find_by_email(params["email"])
          
          if person then
            @output["success"] = false
            @output["errors"] ||= []
            @output["errors"] << "User name has already been taken."
          else
            if params["password"] != params["confirm"] then
              @output["success"] = false
              @output["errors"] ||= []
              @output["errors"] << "Password and Confirmation does not match."
            else
              @output.success = true
              
              person = Person.new
              person.email = params["email"]
              person.password = Digest::SHA1.hexdigest params["password"]
              person.join_community_named(Config.get("default_community"))
              person.save
                
              session[:current_user] = person.id
            end
          end
          
          @output.to_json
        end
        
        get prefix + '/profile/view' do
          return unless verify_current_user("You have to be logged in to view your profile.")
          
          @output = {}
          
          person = Person.find_by_id(session[:current_user])
          @output["value"] = person.to_hash_for_event
          @output["success"] = true
          
          @output.to_json
        end
        
        post prefix + '/profile/write' do
          return unless verify_current_user("You have to be logged in to write to your profile.")
          
          @output = {}
          
          person = Person.find_by_id(session[:current_user])
          success = person.write_profile(params["value"])
          person.save if success
          @output["success"] = success
          
          @output.to_json
        end
        
        post prefix + '/profile/update' do          
          return unless verify_current_user("You have to be logged in to update your profile.")
          
          @output = {}
          
          person = Person.find_by_id(session[:current_user])
          success = person.update_profile(params["value"])
          person.save if success
          @output["success"] = success
          
          @output.to_json
        end
        
        
        # TODO - Privacy considerations need to go here...
        
        
        get prefix + '/people/search' do
          @output = {}
          
          @output["results"] = Person.search(params["query"])
          @output["success"] = true
          
          @output.to_json
        end
        
        get prefix + '/people/:id' do
          @output = {}
          
          person = Person.find_by_id(params["id"])
          if person then
            @output["person"] = person.to_hash_for_event
            @output["success"] = true
          else
            @output["success"] = false
            @output["errors"] ||= []
            @output["errors"] << "Could not find the user with that identifier."
          end
          
          @output.to_json
        end
        
        post prefix + '/community/:name/join' do
          return unless verify_current_user("You have to be logged in to join a community.")          
          
          @output = {}
          
          person = Person.find_by_id(session[:current_user])
          success = person.join_community_named(params["name"])
          @output["success"] = success
          
          @output.to_json
        end
        
        post prefix + '/community/:name/leave' do
          return unless verify_current_user("You have to be logged in to leave a community.")
          
          @output = {}
          
          person = Person.find_by_id(session[:current_user])
          success = person.leave_community_named(params["name"])
          @output["success"] = success
          
          @output.to_json
        end
        
        
        
        
        get prefix + '/stream/poll' do
          
          # TODO
          
        end
        
        
        
        
        get prefix + '/stream/tracks' do
          
          
        end
        
        get prefix + '/stream/tracks/root' do
          
        end
        
        get prefix + '/stream/tracks/:id ' do
          
        end
        
        
        
        
        get prefix + '/stream/events' do
          
        end
        
        get prefix + '/stream/events/:id' do
          
        end
        
        post prefix + '/stream/events/:id' do
          
        end
        
        
        
        
        get prefix + '/stream/tasks' do
          return unless verify_current_user("You have to be logged in to view tasks.")
          
          @output = {}
          
          # TODO Task options
          current_user = Person.find_by_id(session[:current_user])
          @output["tasks"] = RoutedTask.for_person(current_user, {:completed => params["completed"], :type => params["type"]})
          @output["success"] = true
          
          @output.to_json
        end
        
        get prefix + '/stream/tasks/:id' do
          return unless verify_current_user("You have to be logged in to view tasks.")
          
          @output = {}
          
          current_user = Person.find_by_id(session[:current_user])
          task = RoutedTask.find_by_id(params["id"])
          
          if task.route_to_person? current_user then
            @output["success"] = true
            @output["task"] = task.to_hash_for_event
          else
            @output["success"] = false
            @output["errors"] ||= []
            @output["errors"] << "You are not eligible for this task."
          end
          
          @output.to_json
        end
        
        post prefix + '/stream/tasks/:id' do
          return unless verify_current_user("You have to be logged in to respond to tasks.")
          
          @output = {}
          
          current_user = Person.find_by_id(session[:current_user])
          current_task = RoutedTask.find_by_id(params["id"])
          
          if current_task.route_to_person?(current_user) then
            current_task.process_response(params["response"], current_user)
            current_task.save
            Variable.notify_handlers_for_task(current_task)
            @output["success"] = true
          else
            @output["success"] = false
            @output["errors"] ||= []
            @output["errors"] << "You are not eligible for this task"
            return
          end          
          
          @output.to_json
        end
        
        
        
        
        get prefix + '/stream/messages' do
          return unless verify_current_user("You have to be logged in to view messages.")
          
          @output = {}
          
          current_user = Person.find_by_id(session[:current_user])
          @output["messages"] = RoutedMessage.for_person(current_user)
          @output["success"] = true
          
          @output.to_json
        end
        
        get prefix + '/stream/messages/:id' do
          return unless verify_current_user("You have to be logged in to view messages.")
          
          @output = {}
          
          current_user = Person.find_by_id(session[:current_user])
          message = RoutedMessage.find_by_id(params["id"])
          
          if message.route_to_person? current_user then
            @output["success"] = true
            @output["message"] = message.to_hash_for_event
          else
            @output["success"] = false
            @output["errors"] ||= []
            @output["errors"] << "You are not eligible for this message."
          end
          
          @output.to_json
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
        Server.initialize
        
        tracks = Track.find({"state" => Track::STATE::RUNNING}, :sort => ["created_at", Mongo::DESCENDING])
        
        for track in tracks do
          track = Track.from_hash(track)
          track.continue
        end
        
        tracks = Track.find({"state" => Track::STATE::RUNNING}, :sort => ["created_at", Mongo::DESCENDING])
        
        if tracks.count != 0 then
          Thin::Server.start '0.0.0.0', Config.get('port'), Server
        end
      end
      
    end
 
  end
  
end