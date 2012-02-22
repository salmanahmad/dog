#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class Environment
    
    class << self
      attr_accessor :program_path
      
      def program_path=(path)
        @program_path = File.absolute_path(path)
      end
      
      def program_directory
        File.dirname(@program_path)
      end
      
      def dormouse_access_token_url(code)
        "#{Config.get('dormouse_server')}/oauth/access_token?project_id=#{Config.get('dormouse_project')}&api_key=#{Config.get('dormouse_key')}&code=#{code}"
      end
      
      def dormouse_new_session_url
        URI.escape("#{Config.get('dormouse_server')}/api/v1/plugins/new_session?project_id=#{Config.get('dormouse_project')}&redirect_uri=http://localhost:#{Config.get('port')}/authenticate")
      end
      
      def dormouse_new_account_url
        URI.escape("#{Config.get('dormouse_server')}/api/v1/plugins/new_account?project_id=#{Config.get('dormouse_project')}&redirect_uri=http://localhost:#{Config.get('port')}/authenticate")
      end
      
      def reset
        Config.reset
        Variable.reset
        Server.reset
      end
      
    end
    
  end
  
end