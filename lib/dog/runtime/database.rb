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
  
  module Database
    class << self
      
      def initialize
        return if @initialized
        @initialized = true
        
        connection = Config.get "database"

        if connection then
          self.database = Sequel.connect(connection)  
        else
          # TODO - the name of the file. I can't use $0 here though, right?
          self.database = Sequel.connect("sqlite://dog.db")  
        end

        self.database.create_table? :tracks do
          primary_key :id
          foreign_key :parent_id, :tracks
          integer :checkpoint

          index :id
          index :parent_id
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
          foreign_key :person_id, :people
          string :name
          text :value

          index :id
          index :track_id
          index :person_id
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
          foreign_key :person_id, :people
          foreign_key :community_id, :communities

          index :person_id
          index :community_id
          index [:person_id, :community_id], :unique => true
        end

        self.database.create_table? :people do
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

        self.database.create_table? :person_properties do
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

        self.database.create_table? :person_relationships do
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

        self.database.create_table? :events do
          primary_key :id
          foreign_key :person_id, :people
          text :properties
        end

      end 
    end
  end    
end
