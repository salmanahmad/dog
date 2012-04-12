#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  def self.wait(variable = nil)
    if variable then
      # TODO - Do something with waiting on a variable
    end
    
    Fiber.yield
  end
  
  def self.reply(data)
    fiber = Fiber.current.context[:reply_fiber]
    
    if fiber && fiber.alive? then
      fiber.resume(data)
    end
  end
  
  def self.ask(users, task, options = {})
    users = People.from_list(users) if users.kind_of?(Array)
    
    if task.kind_of? Task then
      unless task.required_input_present?
        raise "Required input parameters are missing."
        return
      end
      
      routed_task = RoutedTask.new
      routed_task.type = task.class
      routed_task.value = task.to_hash
      routed_task.routing = users
      routed_task.replication = options[:replication]
      routed_task.duplication = options[:duplication]
      
      routed_task.save
      
      return routed_task
    elsif task.kind_of? Workflow then
      unless task.required_input_present?
        raise "Required input parameters are missing."
        return
      end
      
      routed_workflow = RoutedWorkflow.new
      routed_workflow.type = task.class
      routed_workflow.value = task.to_hash
      routed_workflow.routing = users
      routed_workflow.save
      
      # TODO - I need to set the control and access links correctly
      track = Track.create(:parent_id => Track.root.id)
        
      fiber = TrackFiber.new do
        task.run
      end
        
      variable = Variable.create(task.class.people_variable_name, track)
      variable.type = People
      variable.value = users
      variable.save
      
      track.fiber = fiber
      track.fiber.resume
    end
  end
  
  def self.notify(users, message)
    users = People.from_list(users) if users.kind_of?(Array)
    
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
      return routed_message
    end
    
  end
end