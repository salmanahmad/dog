
module Dog

  class Server < Sinatra::Base

    module Facebook
      include HTTParty
      extend Rack::Utils

      base_uri "https://graph.facebook.com"

      # test with: http://localhost:8080/dog/account/facebook/login
      def self.oauth_dialog_url(request, session)
        permissions = [ 'user_actions:dog-lang' ]
        bytes = SecureRandom.random_bytes(16)
        session[:oauth_state] = Digest::SHA1.base64digest bytes
        qs = URI::encode_www_form({
          'client_id' => Config::get('facebook_app_id'),
          'redirect_uri' => redirect_uri(request),
          'scope' => permissions.join(','),
          'state' => session[:oauth_state]
        })
        return "https://www.facebook.com/dialog/oauth?" + qs
      end

      def self.oauth_callback(request, session, params)
        output = {}
        if params['error'] or (params['state'] != session[:oauth_state]) then
          return error_output params['error']['message'] || "Possible CSRF attack taking place."
        end
        access_token_response = self.oauth_get_access_token(request, params)
        return error_output access_token_response['error']['message'] if access_token_response['error']
        person = self.update_current_person access_token_response
        return error_output "Fetching your information failed." if not person
        session[:current_user] = person.id
        output = {}
        output["success"] = true
        output
      end

      def self.redirect_uri(request)
        request.scheme + "://" + request.host_with_port + Config::get('dog_prefix') + '/account/facebook/login'
      end

      def self.error_output(error_msg)
        output = {}
        output["success"] = false
        output["errors"] ||= []
        output["errors"] << error_msg
        output
      end

      def self.oauth_get_access_token(request, params)
        response = self.get( '/oauth/access_token', :query => {
          'client_id' => Config::get('facebook_app_id'),
          'client_secret' => Config::get('facebook_app_secret'),
          'redirect_uri' => redirect_uri(request),
          'code' => params['code']
        })
        parse_query response.body
      end

      def self.update_current_person(access_token_response)
        response = self.get( '/me', :query => {
          access_token: access_token_response['access_token']
        })
        me_info = JSON::parse response.body
        return nil if me_info['error']
        person = Person.find_by_facebook_id(me_info['id'])
        unless person
          person = Person.new
        end
        person.first_name = me_info['first_name']
        person.last_name = me_info['last_name']
        expires = access_token_response['expires'].to_i # in seconds
        person.add_facebook_profile(me_info['id'], {
          access_token: access_token_response['access_token'],
          access_token_expires: Time.now() + expires,
          username: me_info['username'] || person.facebook && person.facebook[:username],
          link: me_info['link'] || person.facebook && person.facebook[:link]
        })
        person.save
        person
      end

    end

  end
end
