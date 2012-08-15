
require 'pp'

module Dog
  class FacebookHelpers
    include HTTParty
    extend Sinatra::Helpers
    extend Rack::Utils

    base_uri "https://graph.facebook.com"

    class << self

      # test with: http://localhost:8080/dog/account/facebook/login
      def oauth_dialog_url(request)
        session = request.session
        permissions = [ 'user_actions:dog-lang' ]
        bytes = SecureRandom.random_bytes(16)
        session[:oauth_state] = Digest::SHA1.base64digest bytes
        return url("https://www.facebook.com/dialog/oauth?" +
          Helper::URI::to_qs({
            'client_id' => Config::get('facebook_app_id'),
            'redirect_uri' => escape( redirect_uri(request) ),
            'scope' => permissions.map { |p| escape(p) }.join(','),
            'state' => escape(session[:oauth_state])
          })
        )
      end

      def oauth_callback(request)
        session = request.session
        params = request.params
        output = {}
        if params['error'] or (params['state'] != session[:oauth_state]) then
          return error_output params['error']['message'] || "Possible CSRF attack taking place."
        end
        access_token_response = self.oauth_get_access_token(request)
        return error_output access_token_response['error']['message'] if access_token_response['error']
        person = self.update_current_person access_token_response
        return error_output "Fetching your information failed." if not person
        session[:current_user] = person.id
        output = {}
        output["success"] = true
        output
      end

      def redirect_uri(request)
        request.scheme + "://" + request.host_with_port + Config::get('dog_prefix') + '/account/facebook/login'
      end

      def error_output(error_msg)
        output = {}
        output["success"] = false
        output["errors"] ||= []
        output["errors"] << error_msg
        output
      end

      def oauth_get_access_token(request)
        params = request.params
        response = self.get( '/oauth/access_token', :query => {
          'client_id' => Config::get('facebook_app_id'),
          'client_secret' => Config::get('facebook_app_secret'),
          'redirect_uri' => redirect_uri(request),
          'code' => params['code']
        })
        parse_query response.body
      end

      def update_current_person(access_token_response)
        response = self.get( '/me', :query => {
          access_token: access_token_response['access_token']
        })
        me_info = JSON::parse response.body
        # FIXME debug output
        pp me_info
        return nil if me_info['error']
        person = FacebookPerson.find_by_facebook_id(me_info['id'])
        unless person
          person = FacebookPerson.new
        end
        person.first_name = me_info['first_name']
        person.first_name = me_info['last_name']
        # convert to days
        expires = access_token_response['expires'].to_f / (24 * 60 * 60)
        person.add_facebook_profile(me_info['id'], {
          access_token: access_token_response['access_token'],
          access_token_expires: DateTime.now() + expires,
          username: me_info['username'] || person.facebook && person.facebook[:username],
          link: me_info['link'] || person.facebook && person.facebook[:link]
        })
        person
      end

    end
  end
end
