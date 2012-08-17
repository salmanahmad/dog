
module Dog
  module FacebookPerson

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def find_by_facebook_id(fb_id)
        return nil unless self.facebook
        find_one({"facebook.id" => fb_id}) rescue nil
      end
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
      self.facebook = self.facebook || {}
      self.facebook.merge! profile
      self
    end

  end
end
