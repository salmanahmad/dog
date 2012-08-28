#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  class Person < DatabaseObject
    include Dog::FacebookPerson

    # sets the collection_name in DatabaseObject
    collection "people"

    class << self
      def default_properties
        # TODO - Used by the old People class for predicates
        return [
          "_id",
          "first_name",
          "last_name",
          "handle",
          "email",
          "facebook_profile",
          "twitter",
          "google",
          "communities",
          "profile"
        ]
      end
    end

    def self.attribute(*vars)
      for var in vars do
        self.instance_eval do
          define_method var do
            if var == :_id then
              self.dog_value._id
            elsif var == :id then
              self.dog_value._id
            elsif self.dog_value && self.dog_value[var.to_s] then
              self.dog_value[var.to_s].ruby_value
            else
              nil
            end
          end
          
          define_method "#{var}=".intern do |value|
            self.dog_value[var.to_s] = ::Dog::Value.from_ruby_value(value)
          end
        end
      end
    end

    def initialize(dog_value = nil)
      @dog_value = dog_value

      if @dog_value.nil? then
        # TODO - Fix this so that I can call Dog functions from ruby 
        # more easily. The problem here is that the dog runtime may not
        # always be running which means that Track#new will break when 
        # getting the current package
        @dog_value = ::Dog::Value.new("people.person", {})
      end
    end

    attr_accessor :dog_value

    attribute :_id
    attribute :id
    attribute :first_name
    attribute :last_name
    attribute :handle
    attribute :email
    attribute :facebook_profile
    attribute :twitter
    attribute :google
    attribute :password
    attribute :communities
    attribute :profile

    def to_hash
      self.dog_value.to_hash
      
      # TODO - Remove this cruft
      #hash = {
      #  first_name: self.first_name,
      #  last_name: self.last_name,
      #  handle: self.handle,
      #  email: self.email,
      #  facebook: self.facebook,
      #  twitter: self.twitter,
      #  google: self.google,
      #  password: self.password,
      #  communities: self.communities,
      #  profile: self.profile
      #}
      #
      #hash.delete(:handle) unless hash[:handle]
      #hash.delete(:email) unless hash[:email]
      #hash.delete(:facebook) unless hash[:facebook]
      #hash.delete(:twitter) unless hash[:twitter]
      #hash.delete(:google) unless hash[:google]
      #
      #return hash
    end

    def self.from_hash(hash)
      person = self.new
      person.dog_value = ::Dog::Value.from_hash(hash)
      
      return person
    end

    def save
      ::Dog::database[self.collection_name].save(self.to_hash, {:safe => true, :upsert => true})
    end

    def to_hash_for_event
      hash = self.to_hash.ruby_value
      hash["id"] = self.id
      hash.delete(:password)
      return hash
    end

    def self.search(query)
      query = Regexp.new(query)
      self.find({"$or" => [
        {"value.s:first_name" => query},
        {"value.s:last_name" => query},
        {"value.s:handle" => query},
        {"value.s:email" => query}
      ]}).to_a
    end

    def self.find_by_email(email)
      self.find_one({"value.s:email.value" => email})
    end

    def self.find_ids_for_predicate(conditions)
      self.find(conditions, {:fields => ["_id"]}).to_a
    end

    def accepts_routing?(predicate)
      # TODO - Optimize this with client side evaluation. For now I suppose this is okay...
      
      raise "A person must be saved before matching it against a predicate." unless self.id
      predicate["_id"] = self.id
      
      if self.class.find_one(predicate) then
        return true
      else
        return false
      end
    end


    # Antiquated code, **do not use**
    # -------------------------------
    #
    # Till the end of the class Person
    #



    def join_community(community)
      # Note: This adds the community to the profile but does not
      # save the actual person object. You have to call #save. This
      # was done so that we can ensure atomic updates

      return nil if community.nil?

      self.communities ||= []
      self.communities = self.communities | [community.name]

      self.profile ||= {}
      self.profile[community.name] ||= {}

      for key, value in community.properties do
        unless self.profile[community.name].include?(key) then
          self.profile[community.name][key] = nil
        end
      end

      return true
    end

    def join_community_named(community_name)
      join_community(Community.find_by_name(community_name))
    end

    def leave_community(community)
      # Note: Just like join, this does not save the object
      
      return nil if community.nil?
      self.communities ||= []
      self.communities = self.communities - [community.name]
      
      self.profile ||= {}
      self.profile.delete(community.name)
      
      return true
    end
    
    def leave_community_named(community_name)
      leave_community(Community.find_by_name(community_name))
    end
    
     # TODO - Clean up all of these update methods...
    
    def update_profile(properties = {})
      # TODO - Validate profile information with community type definitions
      old_profile = self.profile
      
      begin
        for key, value in properties do
          community = Community.find_by_name(key)
          self.update_profile_for_community(community, value) if community
        end
      rescue => exception
        self.profile = old_profile
        raise exception
      end
    end
    
    def update_profile_for_community(community, properties)
      self.profile ||= {}
      self.profile[community.name] ||= {}
      
      old_profile = self.profile[community.name]
      
      for key, value in properties do
        next unless community.properties.include? key
        
        property = community.properties[key]
        type = property["type"]
        
        if type then
          converted_value = Structure.convert_value_to_type(value, type)
          if !converted_value.nil? || value.nil? then
            self.profile[community.name][key] = converted_value
          end
        else
          self.profile[community.name][key] = value
        end
      end
    end
    
    def write_profile(properties = {})
      # TODO - Validate profile information with community type definitions
      old_profile = self.profile
      
      begin
        for key, value in properties do
          community = Community.find_by_name(key)
          self.write_profile_for_community(community, value) if community
        end
      rescue => exception
        self.profile = old_profile
        raise exception
      end
    end
    
    def write_profile_for_community(community, properties = {})
      self.profile ||= {}
      self.profile[community.name] ||= {}
      
      old_profile = self.profile[community.name]
      self.profile[community.name] = {}
      
      for key, value in properties do
        next unless community.properties.include? key
        
        property = community.properties[key]
        type = property["type"]
        
        if type then
          converted_value = Structure.convert_value_to_type(value, type)
          if !converted_value.nil? || value.nil? then
            self.profile[community.name][key] = converted_value
          end
        else
          self.profile[community.name][key] = value
        end
      end
    end
    
    def push_profile(properties = {})
      # TODO - Validate profile information with community type definitions
      old_profile = self.profile
      
      begin
        for key, value in properties do
          community = Community.find_by_name(key)
          self.push_profile_for_community(community, value) if community
        end
      rescue => exception
        self.profile = old_profile
        raise exception
      end
    end
    
    def push_profile_for_community(community, properties = {})
      self.profile ||= {}
      self.profile[community.name] ||= {}
      
      old_profile = self.profile[community.name]
      
      for key, value in properties do
        next unless community.properties.include? key
        
        property = community.properties[key]
        type = property["type"]
        
        if type == Array && value.class == Array then
          self.profile[community.name][key] ||= []
          self.profile[community.name][key] |= value
        end
      end
    end
    
    def pull_profile(properties = {})
      # TODO - Validate profile information with community type definitions
      old_profile = self.profile
      
      begin
        for key, value in properties do
          community = Community.find_by_name(key)
          self.pull_profile_for_community(community, value) if community
        end
      rescue => exception
        self.profile = old_profile
        raise exception
      end
    end
    
    def pull_profile_for_community(community, properties = {})
      self.profile ||= {}
      self.profile[community.name] ||= {}
      
      old_profile = self.profile[community.name]
      
      for key, value in properties do
        next unless community.properties.include? key
        
        property = community.properties[key]
        type = property["type"]
        
        if type == Array && value.class == Array then
          self.profile[community.name][key] ||= []
          self.profile[community.name][key] -= value
        end
      end
    end
    
  end
  
  class People
    
    attr_accessor :community_hint
    
    def self.to_database(object)
      rename(object, true)
    end
    
    def self.from_database(object)
      rename(object, false)
    end
    
    def self.rename(object, to_database)
      if object.kind_of? Array then
        object.map! do |value|
          if value.kind_of?(Array) || value.kind_of?(Hash) then
            rename(value, to_database)
          else
            value
          end
        end
      elsif object.kind_of? Hash then
        object.keys.each do |key|
          
          search = "$"
          replace = "@"
          
          if !to_database then
            search = "@"
            replace = "$"
          end
          
          
          if key[0] == search then
            old_key = key
            
            key = key[1..-1]
            key = replace + key
            
            object[key] = object[old_key]
            object.delete(old_key)
          end
          
          value = object[key]
          if value.kind_of?(Array) || value.kind_of?(Hash) then
            object[key] = rename(value, to_database)
          end
        end
        return object
      end
    end
    
    
    def self.from_list(people)
      ids = []
      for person in people do
        ids << person._id
      end
      
      return {"_id" => {"$in" => ids}}
    end
    
    def self.from(community)
      people = People.new
      people.from(community)
    end
    
    def self.where(conditions)
      people = People.new
      people.where(conditions)
    end
    
    def from(community)
      self.community_hint = community
      return self
    end
    
    def where(conditions)
      update_conditions(conditions)
    end
    
    def update_conditions(conditions)
      updated_conditions = {}
      boolean_operators = ["$and", "$or", "$nor"]
      
      for key, value in conditions do
        if boolean_operators.include?(key)
          value = updated_conditions(value)
        elsif key.include?("$") || key.include?(".")
          # Do nothing
        elsif Person.default_properties.include? key
          # DO nothing
        else
          key = "profile.#{self.community_hint}.#{key}"
        end
        
        updated_conditions[key] = value
      end
      
      return updated_conditions
    end
    
  end
  
end