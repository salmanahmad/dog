#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog  
  class RoutedMessage < Sequel::Model(:messages)
    plugin :single_table_inheritance, :kind
    plugin :serialization, :json, :value
    
    # TODO - Setup many-to-many relationships
    # many_to_many :people, :class => :person, :join_table => :person_messages, :left_key => :messages_id, :right_key => :person_id
  end
  
  class Message < Structure
    
  end
end