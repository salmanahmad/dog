#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog

  module Language

    def self.singularize(word)
      return word.chop
    end

    def self.pluralize(word)
      return "#{word}s"
    end

  end

  module Helper
    
    def self.person_matches_routing(person, routing)
      return true if routing.nil? or routing.size <= 0

      if (person._id == routing["_id"]) then
        return true
      else
        return false
      end
    end
    
    def self.routing_for_actor(routing = nil)
      if routing.type == "people.person" then
        return {"_id" => routing._id}
      else
        return nil
      end
    end
    
    def self.underscore(string)
      string.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
    end

    def self.unique_number
      @unique ||= 0
      @unique += 1
      return @unique
    end

  end
end
