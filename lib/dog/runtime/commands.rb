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
      
      ::Dog.database.transaction do
        task = RoutedTask.new
        task.replication = 1
        task.duplication = 1
        task.value = task
        task.save
        
        users = [users] if users.class != Array
        
        for user in users
          ::Dog.database[:person_tasks].insert(:person_id => user.id, :task_id => task.id)
        end
      end
    end
  end
  
  def self.notify(users, message)
    if task.kind_of? Message then
      unless task.required_input_present?
        raise "Required input parameters are missing."
        return
      end
      
      ::Dog.database.transaction do
        message = RoutedMessage.new
        message.value = message
        message.save
        
        users = [users] if users.class != Array
        
        for user in users
          ::Dog.database[:person_messages].insert(:person_id => user.id, :message_id => message.id)
        end
      end
    end
    
  end
end