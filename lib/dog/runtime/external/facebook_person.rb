
module Dog
  class FacebookPerson < Person
    # not sure what this does
    # collection "facebook"

    def self.find_by_facebook_id(fb_id)
      self.find_one({"facebook.id" => fb_id})
    end

    def add_facebook_profile(fb_id, access_token=nil, ac_expires=nil, username=nil)
      profile = {
        id: fb_id,
        access_token: access_token,
        ac_expires: ac_expires,
        username: username
      }
      self.facebook = profile
      self
    end

  end
end
