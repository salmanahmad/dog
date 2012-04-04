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
  
  def self.ask(users, task)
    if task.kind_of? Task then
      unless task.required_input_present?
        raise "Required input parameters are missing."
        return
      end
      
      routed_task = RoutedTask.new
      routed_task.type = task.class
      routed_task.value = task.to_hash
      routed_task.routing = users
      routed_task.save
    end
  end
  
  def self.notify(users, message)
    if task.kind_of? Message then
      unless task.required_input_present?
        raise "Required input parameters are missing."
        return
      end
      
      routed_message = RoutedMessage.new
      routed_message.type = message.class
      routed_message.value = message.to_hash
      routed_message.routing = users
      routed_message.save
    end
    
  end
end