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
    collection "people"
    
    def self.default_properties
      return [
        "_id",
        "handle",
        "email",
        "facebook",
        "twitter",
        "google",
        "communities",
        "profile"
      ]
    end
    
    attr_accessor :_id
    attr_accessor :handle
    attr_accessor :email
    attr_accessor :facebook
    attr_accessor :twitter
    attr_accessor :google
    attr_accessor :password
    attr_accessor :communities
    attr_accessor :profile
    
    # For routing
    attr_accessor :last_task_id
    attr_accessor :last_message_id
    attr_accessor :last_workflow_id
    
    def to_hash
      return {
        handle: self.handle,
        email: self.email,
        facebook: self.facebook,
        twitter: self.twitter,
        google: self.google,
        password: self.password,
        communities: self.communities,
        profile: self.profile,
        last_task_id: self.last_task_id,
        last_message_id: self.last_message_id,
        last_workflow_id: self.last_workflow_id
      }
    end
    
    def to_hash_for_event
      hash = self.to_hash
      hash[:_id] = self._id
      hash.delete(:password)
      hash.delete(:last_task_id)
      hash.delete(:last_message_id)
      hash.delete(:last_workflow_id)
      return hash
    end
    
    def self.search(query)
      # TODO
    end
    
    def self.find_by_email(email)
      self.find_one({"email" => email})
    end
    
    def join_community(community)
      # Note: This adds the community to the profile but does not
      # save the actual person object. You have to call #save. This
      # was done so that we can ensure atomic updates
      
      return nil if community.nil?
      self.communities ||= []
      self.communities = self.communities | [community.name]
      
      self.profile ||= {}
      self.profile[community.name] ||= {}
      
      for key, value in community do
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
    
    def update_profile(properties = {})
      # TODO - Validate profile information with community type definitions
      old_profile = self.profile
      
      begin
        for key, value in properties do
          community = Community.find_by_name(key)
          self.update_profile_for_community(community, value)
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
          self.profile[community.name][key] = Properties.convert_value_to_type(value, type)
        else
          self.profile[community.name][key] = value
        end
      end
    end
    
    def write_profile
      # TODO...
    end
    
    def push_profile
      # TODO...
    end
    
    def pull_profile
      # TODO...
    end
    
    def accepts_routing?(predicate)
      # TODO - Optimize this with client side evaluation. For now I suppose this is okay...
      
      raise "A person must be saved before matching it against a predicate." unless self._id
      predicate["_id"] = self._id
      
      if self.find_one(predicate) then
        return true
      else
        return false
      end
    end
    
  end
  
  class People
    
    attr_accessor :community_hint
    
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