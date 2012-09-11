
module Dog
  module FacebookPerson

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def find_by_facebook_id(fb_id)
        find_one({"value.s:facebook_profile.value.s:id.value" => fb_id})
      end
    end

    def add_facebook_profile(fb_id, optionals)
      if self.dog_value["facebook_profile"] && self.dog_value["facebook_profile"].is_null? then
        self.dog_value["facebook_profile"] = Value::empty_structure
      end
      self.dog_value["facebook_profile"]["id"] = Value::string_value fb_id
      optionals.each do |k, v|
        self.dog_value["facebook_profile"][k.to_s] = Value::string_value v
      end
      self.dog_value["facebook_profile"]["friends"] = Value::empty_array
    end

  end
end
