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
    
    # TODO - 
      # Find all of the users 
      # Read users
      # Update a users's profile information
      # Add a user to a relationship profile field
    
    # TODO - Adding output fields for all of these events...
    
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
        property "track_id", :type => String, :required => true, :direction => "input"
      end
      
      class List < SystemEvent
        # TODO - ObjectId as a type
        # TODO - Default values for properties. This is useful for profile
        # stuff as well when initializing the user's profile
        property "type", :type => String, :direction => "input"
        property "track_id", :type => String, :direction => "input"
        property "limit", :type => String, :direction => "input"
        property "offset", :type => String, :direction => "input"
      end
      
    end
    
    class Messages < SystemEvent
      
      class View < SystemEvent
        property "message_id", :type => String, :required => true, :direction => "input"
      end
      
      class List < SystemEvent
        property "type", :type => String, :direction => "input"
        property "track_id", :type => String, :direction => "input"
        property "limit", :type => String, :direction => "input"
        property "offset", :type => String, :direction => "input"
      end
      
    end
    
    class Workflows < SystemEvent
      
      class List < SystemEvent
        property "type", :type => String, :direction => "input"
        property "limit", :type => String, :direction => "input"
        property "offset", :type => String, :direction => "input"
      end
      
    end
    
    
  end  
end