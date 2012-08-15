
require 'sinatra/base'

module Dog
  class FacebookHelpers
    class << self

      def oauth_dialog_url()
        fb_app_id = 'abcd'
        protocol = 'http'
        host = 'localhost:8080'
        permissions = [ 'ij', 'kl' ]
        oauth_state = 'mnop'
        # uri(
        return ("https://www.facebook.com/dialog/oauth?" +
          ::Helper::URI::to_qs({
            'client_id' => fb_app_id
            # 'redirect_uri' => escape( protocol + '://' + host + '/login' ),
            # 'scope' => permissions.join(','),
            # 'state' => escape(oauth_state)
          })
        )
      end
    end
  end
end
