#
# Copyright 2011 by Rizwan Ahmad (rizwanahmad93@gmail.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog

  class Server < Sinatra::Base
    class << self
      def initialize_vet
        return if @initialize_vet
        @initialize_vet = true

        prefix = Config.get('dog_prefix')
        prefix += "/vet"

        Dir.foreach(File.join(File.dirname(__FILE__), "vet")) do |f|
          full_path = File.join(File.dirname(__FILE__), "vet", f)
          unless [".", "..", "index.html", "login.html"].include? f then
            route = prefix + "/" + f
            get route do
              send_file full_path
            end
          end
        end
        
        get prefix + "/index.html" do
          if(session["login"] == true)
            file = File.join(File.dirname(__FILE__), "vet", "index.html")
            file = File.open(file)
            return file.read
#            send_file File.join(File.dirname(__FILE__), "vet", "index.html")
          else
            redirect prefix + "/login.html"
          end
        end

        get prefix + "/login.html" do
          if(session["login"] == true)
            redirect prefix + "/index.html"
          else
            send_file File.join(File.dirname(__FILE__), "vet", "login.html")
          end
        end

        post prefix + "/login.html" do
          @username = params["username-field"]
          @password = params["password-field"]
          if(@username == "username" && @password == "password")
            session["login"] = true
            redirect prefix + "/index.html"
          else
            session["login"] = false
            redirect prefix + "/login.html"
          end
        end
        
        post prefix + "/logout.html" do
          session["login"] = false
          redirect prefix + "/login.html"
        end
      end
    end
  end
end
