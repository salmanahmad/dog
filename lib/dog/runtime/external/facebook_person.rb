
module Dog
  class FacebookPerson < Person
    # not sure what this does
    # collection "facebook"

    def self.find_by_facebook_id(fb_id)
      self.find_one({"facebook.id" => fb_id}) rescue nil
    end

    def add_facebook_profile(fb_id, optionals)
      profile = {
        id: fb_id,
        access_token: optionals[:access_token],
        access_token_expires: optionals[:access_token_expires],
        username: optionals[:username],
        link: optionals[:link],
        friends: []
      }
      self.facebook = profile
      self
    end

  end
end
