#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  class RoutedTask < Sequel::Model(:tasks)
    plugin :single_table_inheritance, :kind
    plugin :serialization, :json, :value
    
    one_to_many :task_responses
    
    # TODO - Setup many-to-many relationships
    # many_to_many :people, :class => :person, :join_table => :person_tasks, :left_key => :task_id, :right_key => :person_id
  end
  
  class TaskResponse < Sequel::Model(:task_responses)
    plugin :serialization, :json, :value
    
    many_to_one :task, :class => RoutedTask
    many_to_one :responder, :class => Person
  end
  
  class Task < Structure
    
  end
end

