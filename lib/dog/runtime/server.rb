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

    # CORS Supports
    # TODO - Support JSONP

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

    helpers do
      def layout(name)
        # Intentionally blank. Used by our template system.
      end
      
      def account_status
        if session[:current_user]
          return {
            "authenticated" => true,
            "email" => nil,
            "name" => nil
          }
        else
          return {
            "authenticated" => false
          }
        end
      end
      
      def find_or_generate_current_user
        # TODO - Facebook will not work until you refactor this


        person = Person.find_by_id(session[:current_user])

        if person.nil? then
          if session[:current_user_object] then
            person = ::Dog::Person.from_hash(session[:current_user_object])
          else
            person = ::Dog::Person.new()
            session[:current_user_object] = person.to_hash
            #session[:current_user] = person.id
          end
        end



        return person.dog_value
        

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

    set :assets, Sprockets::Environment.new
    settings.assets.append_path (File.join(File.dirname(__FILE__), "resources/javascripts"))

    class << self

      def initialize
        return if @initialized
        @initialized = true
        
        prefix = Config.get('dog_prefix')

        use Faye::RackAdapter, :mount => (prefix + '/stream'), :timeout => 25, :extensions => []

        # TODO - I have to figure this out for production
        set :static, false
        set :public_folder, Proc.new { File.join(Runtime.bundle_directory, "views") }

        self.initialize_vet

        # TODO - Some stream endpoint for push notifications

        # TODO - Add an OAuth API out of the box

        # TODO - Add some ability to get basic user information. Perhaps their handle and their name?

        get prefix + '/account/status' do
          content_type 'application/json'
          {"account_status" => account_status}.to_json
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
          
          if params['redirect_uri'] then
            redirect params['redirect_uri'] || '/'
          else
            content_type 'application/json'
            {"account_status" => account_status}.to_json
          end
        end

        get prefix + '/account/:provider/login' do |provider|
          if session[:current_user] then
            content_type 'application/json'
            return { "success" => true }.to_json
          end

          @output = {}

          case provider
          when 'facebook'
            unless params['code'] and params['state']
              session[:oauth_redirect] = params['redirect_uri'] || '/'
              return redirect to Facebook::oauth_dialog_url(request, session)
            end
            @output = Facebook::oauth_callback(request, session, params)
          else
            @output["success"] = false
            @output["errors"] ||= []
            @output["errors"] << "Unsupported OAuth provider."
          end

          unless @output["success"]
            content_type 'application/json'
            return @output.to_json
          end
          redirect to(session[:oauth_redirect] || '/')
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
              person.save

              session[:current_user] = person.id
            end
          end

          content_type 'application/json'
          @output.to_json
        end

        # TODO - I don't think that I need to include the original_track at all, actually...

        get prefix + '/track/:id' do |id|
          if id == "root" then
            track = ::Dog::Track.root
          else
            track = ::Dog::Track.find_by_id(id)
          end

          if track.nil? || (!track.is_root? && track.state == ::Dog::Track::STATE::FINISHED) then
            return 404
          else
            content_type 'application/json'
            return {
              "original_track" => track.to_hash_for_api_user(),
              "track" => track.to_hash_for_api_user(),
              "account_status" => account_status
            }.to_json
          end
        end

        post prefix + '/track/:id/:variable' do |id, variable|
          if id == "root" then
            track = ::Dog::Track.root
          else
            track = ::Dog::Track.find_by_id(id)
          end

          if track.nil? || (!track.is_root? && track.state == ::Dog::Track::STATE::FINISHED) then
            return 404
          else
            value = track.listens[variable]
            value = value["value"] if value

            request.body.rewind
            data = JSON.parse(request.body.read) rescue nil

            submitted_value = ::Dog::Value.from_ruby_value(data)
            submitted_value.person = find_or_generate_current_user()

            submission_track = ::Dog::Track.invoke("send:to:value", "future", [value, submitted_value])
            
            ::Dog::Runtime.schedule(submission_track)
            tracks = ::Dog::Runtime.resume

            spawns = []
            progress_track = track.to_hash_for_api_user()
            
            for t in tracks do
              if t.same_trace_as?(track) then
                progress_track = t.to_hash_for_api_user()
              elsif submission_track._id == t._id then
                next
              else
                spawns << t.to_hash_for_api_user()
              end
            end

            output = {
              "original_track" => track.to_hash_for_api_user(),
              "track" => progress_track,
              "spawns" => spawns,
              "account_status" => account_status
            }

            content_type 'application/json'
            return output.to_json
          end
        end

        get prefix + '/dog.js' do
          settings.assets["dog.js"]
        end

        get '*' do
          path = params['splat'].first
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

      def stream_client
        @stream_client ||= Faye::Client.new("http://0.0.0.0:#{Config.get('port')}#{Config.get('dog_prefix')}/stream")
        return @stream_client
      end

      def run
        Server.initialize
        return if @running
        @running = true
        
        Thin::Server.start '0.0.0.0', Config.get('port'), Server
      end
    end

  end

end