#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class Account < SystemEvent

    class SignIn < SystemEvent
      
    end
    
    class SignOut < SystemEvent
      
    end
    
    class Create < SystemEvent
      property "name", :type => String, :required => true, :direction => "input"
    end
    
  end
  
  class Community < SystemEvent

    class Join < SystemEvent
      
    end
    
    class Leave < SystemEvent
      
    end
    
  end
  
end