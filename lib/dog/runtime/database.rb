#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class << self 
    attr_accessor :database
  end
  
  def self.initialize_database
    
    connection = Config.get "database"
    
    if connection then
      self.database = Sequel.connect(connection)  
    else
      # TODO - the name of the file. I can't use $0 here though, right?
      self.database = Sequel.connect("sqlite://dog.db")  
    end

    self.database.create_table? :tracks do
      primary_key :id
      integer :checkpoint

      index :id
    end

    self.database.create_table? :track_parents do
      foreign_key :track_id, :tracks
      foreign_key :parent_id, :tracks

      index :track_id
      index :parent_id
    end

    self.database.create_table? :variables do
      primary_key :id
      foreign_key :track_id, :tracks
      string :name
      text :value

      index :id
      index :track_id
      index :name
      index [:name, :track_id], :unique => true
    end

    self.database.create_table? :communities do
      primary_key :id
      string :name
      text :properties

      index :name
    end

    self.database.create_table? :community_memberships do
      foreign_key :user_id, :users
      foreign_key :community_id, :communities

      index :user_id
      index :community_id
      index [:user_id, :community_id], :unique => true
    end

    self.database.create_table? :users do
      primary_key :id
      string :username
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

    self.database.create_table? :user_properties do
      primary_key :id
      foreign_key :community_id, :communities
      foreign_key :user_id, :users
      string :name
      text :value

      index :name
      index :community_id
      index :user_id
      index [:name, :community_id, :user_id], :unqiue => true
    end

    self.database.create_table? :user_relationships do
      primary_key :id
      foreign_key :community_id, :communities
      foreign_key :user_id, :users
      foreign_key :target_id, :users
      string :name

      index :name
      index :community_id
      index :user_id
      index [:name, :community_id, :user_id]
    end

    self.database.create_table? :events do
      primary_key :id
      foreign_key :user_id, :users
      text :properties
    end
    
  end
  
end
