require "json"
require "date"
require "shellwords"
require "pp"

Sequel::Plugins::Serialization.register_format(:variable_json,
  lambda do |v|
    v.to_json
  end,
  lambda do |v|

    if (v.nil?) then
      return nil
    end

    if (v == "null") then
      return nil
    end

    if (r = Integer(v) rescue false) then
      return r
    end

    if (r = Float(v) rescue false) then
      return r
    end

    if (r = JSON.parse(v) rescue false) then
      return r
    end

    Shellwords::shellwords(v).first

  end
)




string = 'Salman  \'a\'  "w"   "p" Ahmad'

pp Shellwords::shellwords("".to_json).first
pp Shellwords::shellwords(string)
pp Shellwords::shellwords(string.to_json)

puts string
puts string.to_json
puts String(string.to_json)







::Dog.database.create_table? :workflows do
  primary_key :id
  foreign_key :track_id, :tracks
  foreign_key :person_id, :people
  string :name
  
  index :track_id
  index :person_id
end

::Dog.database.create_table? :tracks do
  primary_key :id
  foreign_key :parent_id, :tracks
  boolean :root, :default => false
  integer :checkpoint, :default => 0
  integer :depth, :default => 0
  
  index :parent_id
  index :root
end

::Dog.database.create_table? :track_parents do
  foreign_key :track_id, :tracks
  foreign_key :parent_id, :tracks

  index :track_id
  index :parent_id
end

::Dog.database.create_table? :variables do
  primary_key :id
  foreign_key :track_id, :tracks
  foreign_key :person_id, :people
  string :name
  text :value

  index :id
  index :track_id
  index :person_id
  index :name
  index [:name, :track_id], :unique => true
end

::Dog.database.create_table? :communities do
  primary_key :id
  string :name
  text :properties

  index :name
end

::Dog.database.create_table? :community_memberships do
  foreign_key :person_id, :people
  foreign_key :community_id, :communities

  index :person_id
  index :community_id
  index [:person_id, :community_id], :unique => true
end

::Dog.database.create_table? :people do
  primary_key :id
  string :handle
  string :email
  string :facebook
  string :twitter
  string :google
  string :password

  index :email, :unique => true
  index :facebook, :unique => true
  index :twitter, :unique => true
  index :google, :unique => true
end

::Dog.database.create_table? :person_properties do
  primary_key :id
  foreign_key :community_id, :communities
  foreign_key :person_id, :people
  string :name
  text :value

  index :name
  index :community_id
  index :person_id
  index [:name, :community_id, :person_id], :unqiue => true
end

::Dog.database.create_table? :person_relationships do
  primary_key :id
  foreign_key :community_id, :communities
  foreign_key :person_id, :people
  foreign_key :target_id, :people
  string :name
  
  index :name
  index :community_id
  index :person_id
  index [:name, :community_id, :person_id]
end

::Dog.database.create_table? :person_messages do
  foreign_key :person_id, :people
  foreign_key :message_id, :messages
  
  index :person_id
  index :message_id
end

::Dog.database.create_table? :person_tasks do
  foreign_key :person_id, :people
  foreign_key :task_id, :tasks
  
  index :person_id
  index :task_id
end

::Dog.database.create_table? :messages do
  primary_key :id
  string :kind
  text :value
  
  index :kind
end

::Dog.database.create_table? :tasks do
  primary_key :id
  string :kind
  integer :replication
  integer :duplication
  text :value
  
  index :kind
end

::Dog.database.create_table? :task_responses do
  primary_key :id
  foreign_key :task_id, :tasks
  foreign_key :responder_id, :people
  text :value
  
  index :task_id
  index :responder_id
end
