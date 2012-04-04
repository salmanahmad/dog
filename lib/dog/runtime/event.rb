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
    
    class People < SystemEvent
      
      class Search < SystemEvent
        property "query", :type => String, :required => true, :direction => "input"
        property "results", :type => Array, :required => true, :direction => "output"
      end
      
      class View < SystemEvent
        property "id", :type => String, :required => true, :direction => "input"
        property "person", :type => Hash, :required => true, :direction => "output"
      end
      
    end
    
    class Profile < SystemEvent
      
      class View < SystemEvent
        property "value", :type => Hash, :required => true, :direction => "output"
      end
      
      class Write < SystemEvent
        property "value", :type => Hash, :required => true, :direction => "input"
      end
      
      class Update < SystemEvent
        property "value", :type => Hash, :required => true, :direction => "input"
      end
      
      class Push < SystemEvent
        property "value", :type => Hash, :required => true, :direction => "input"
      end
      
      class Pull < SystemEvent
        property "value", :type => Hash, :required => true, :direction => "input"
      end
      
    end
    
    class Community < SystemEvent

      class Join < SystemEvent
        property "name", :type => String, :required => true, :direction => "input"
      end

      class Leave < SystemEvent
        property "name", :type => String, :required => true, :direction => "input"
      end
    end
    
    class Tasks < SystemEvent
      
      class View < SystemEvent
        property "id", :type => String, :required => true, :direction => "input"
        property "task", :type => Hash, :required => true, :direction => "output"
      end
      
      class List < SystemEvent
        property "type", :type => String, :direction => "input"
        property "track_id", :type => String, :direction => "input"
        property "limit", :type => String, :direction => "input"
        property "offset", :type => String, :direction => "input"
        property "tasks", :type => Array, :required => true, :direction => "output"
      end
      
    end
    
    class Messages < SystemEvent
      
      class View < SystemEvent
        property "id", :type => String, :required => true, :direction => "input"
        property "message", :type => Hash, :required => true, :direction => "output"
      end
      
      class List < SystemEvent
        property "type", :type => String, :direction => "input"
        property "track_id", :type => String, :direction => "input"
        property "limit", :type => String, :direction => "input"
        property "offset", :type => String, :direction => "input"
        property "messages", :type => Array, :required => true, :direction => "output"
      end
      
    end
    
    class Workflows < SystemEvent
      
      class List < SystemEvent
        property "type", :type => String, :direction => "input"
        property "limit", :type => String, :direction => "input"
        property "offset", :type => String, :direction => "input"
        property "workflows", :type => Array, :required => true, :direction => "output"
      end
      
    end
    
    
  end  
end