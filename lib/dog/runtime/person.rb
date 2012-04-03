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
    
    attr_accessor :_id
    attr_accessor :handle
    attr_accessor :email
    attr_accessor :facebook
    attr_accessor :twitter
    attr_accessor :google
    attr_accessor :password
    attr_accessor :communities
    attr_accessor :profile
    
    def to_hash
      return {
        handle: self.handle,
        email: self.email,
        facebook: self.facebook,
        twitter: self.twitter,
        google: self.google,
        password: self.password,
        communities: self.communities,
        profile: self.profile
      }
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
    
    def self.find_by_email(email)
      self.find_one({"email" => email})
    end
    
  end

  class People
    
  end
  
end