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
    Track.current.context[:reply] = data
    Track.current.context[:reply_fiber].resume
  end
  
  def self.ask
    
  end
  
  def self.notify
    
  end
end