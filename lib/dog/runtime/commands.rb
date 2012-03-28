#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  def self.reply(data)
    # TODO - Potentially transform the data
    fiber = Track.current.context[:reply_fiber]
    if fiber && fiber.alive? then
      fiber.resume(data)
    end
  end
  
  def self.ask(users, task, properties)
    
  end
  
  def self.notify(users, message, properties)
    
  end
end