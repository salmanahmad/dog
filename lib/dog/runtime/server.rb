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

      def fetch_stream_items_for_track(track = ::Dog::Track.root)
        # L 335
        stream_items = []
        # fetch StreamObjects
        items = ::Dog::StreamObject.find({"track_id" => track.id})
        items.each do |item|
          item = ::Dog::StreamObject.from_hash(item)
          stream_items << item.to_hash_for_stream
        end

        return stream_items
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

          content_type 'application/json'
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

          content_type 'application/json'
          @output.to_json
        end

        get prefix + '/account/logout' do
          session.clear

          content_type 'application/json'
          return {
            "success" => true
          }.to_json
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

          content_type 'application/json'
          @output.to_json
        end



        get prefix + '/stream' do
          return redirect prefix + '/stream/runtime/root'
        end

        get prefix + '/stream/lexical/:id' do |id|
          stream = {}
          stream["self"] = {}
          stream["lexical"] = []
          stream["runtime"] = []

          depth = (params["depth"] || 1).to_i
          limit = (params["limit"] || 0).to_i
          offset = (params["offset"] || 0).to_i
          after = (params["after"])

          symbol = id.split(".")

          runtime = []
          tracks = ::Dog::Track.find({"function_name" => handler}) # FIXME wtf handler?
          for track in tracks do
            runtime << {
              "id" => track["_id"],
              "name" => track["function_name"]
            }
          end

          stream["self"] = ::Dog::Runtime.symbol_info(symbol)
          stream["lexical"] = ::Dog::Runtime.symbol_descendants(symbol, depth)
          stream["runtime"] = runtime

          content_type "application/json"
          return stream.to_json
        end

        get prefix + '/stream/runtime/:id' do |id|
          stream = {}
          stream["self"] = {}
          stream["lexical"] = []
          stream["runtime"] = []

          depth = (params["depth"] || 1).to_i
          limit = (params["limit"] || 0).to_i
          offset = (params["offset"] || 0).to_i
          after = (params["after"])

          track = case id
          when 'root'
            ::Dog::Track.root
          else
            ::Dog::Track.find_by_id(id)
          end
          if track.nil?
            return [400, {"success" => false, "errors" => ["The runtime id '#{id}' does not correspond to a valid runtime item."] }.to_json]
          end
          stream["self"] = track.to_hash_for_stream
          stream["runtime"] = fetch_stream_items_for_track(track)
          stream["lexical"] = ::Dog::Runtime.symbol_descendants(track.function_name.split('.'), depth)

          content_type 'application/json'
          return stream.to_json
        end

        get prefix + '/stream/object/:id' do |id|
          stream = {}
          stream["self"] = {}
          stream["lexical"] = []
          stream["runtime"] = []

          depth = (params["depth"] || 1).to_i
          limit = (params["limit"] || 0).to_i
          offset = (params["offset"] || 0).to_i
          after = (params["after"])

          object = ::Dog::StreamObject.find_by_id(id)
          stream["self"] = object.to_hash_for_stream

          content_type 'application/json'
          return stream.to_json
        end

        post prefix + '/stream/object/:id' do |id|
          object = ::Dog::StreamObject.find_by_id(id)
          track = ::Dog::Track.new(object.handler)

          argument = {}
          for property in object.properties do
            argument[property.identifier] = params[property.identifier]
            if property.required && argument[property.identifier].nil? then
              return [400, {"success" => false, "errors" => ["The required property '#{property.identifier}' was missing."] }.to_json]
            end
          end

          if object.handler_argument then
            dog_value = ::Dog::Value.from_ruby_value(argument)
            track.write_variable(object.handler_argument, dog_value)
          end

          track.listen_argument = object.handler_argument
          track.save

          ::Dog::Runtime.run_track(track)

          content_type 'application/json'
          return {
            "success" => true
          }.to_json
          
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





        # TODO - I am keep these around in case we want to enable these through a configuration flag
        # Obviously there are pretty big privacy concerns that can take part here.
        # We also may want to consider and explore the idea of "mounting" packages. So we move all of
        # these API end points into a Dog package that are provided by the Dog standard libraries. If
        # the developer wants to, they can add in the packages to their configuration file, much like
        # include Rack or Java middleware.

        unless ::Dog::Config.get("profile_editting") == true then
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
        end

        unless ::Dog::Config.get("people_search") == true then
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
        end

        unless ::Dog::Config.get("community_joining") == true then
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
        end





        # This is very important. Do not remove this or testing will not work
        return self
      end

      def run
        Server.initialize
        Thin::Server.start '0.0.0.0', Config.get('port'), Server
      end

    end

  end

end