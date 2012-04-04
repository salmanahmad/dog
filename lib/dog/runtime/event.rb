#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  class Event < Structure
    property "success", :type => Boolean, :direction => "output"
    property "errors", :type => Array, :direction => "output"    
  end
  
  module SystemEvents
    class SystemEvent < Event
      def self.identifier
        self.name.downcase.split("::")[2..-1].join(".")
      end
    end

    class Account < SystemEvent

      class LoginStatus < SystemEvent
        property "logged_in", :type => Boolean, :direction => "output"
      end

      class Login < SystemEvent
        property "email", :type => String, :direction => "input"
        property "password", :type => String, :direction => "input"
      end

      class Logout < SystemEvent

      end

      class Create < SystemEvent
        property "email", :type => String, :required => true, :direction => "input"
        property "password", :type => String, :direction => "input"
        property "confirm", :type => String, :direction => "input"
      end

    end
    
    class Community < SystemEvent

      class Join < SystemEvent

      end

      class Leave < SystemEvent

      end
    end
  end  
end