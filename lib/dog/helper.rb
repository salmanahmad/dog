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
    
    def self.warn(message)
      puts "Warning: #{message}"
    end
    
    def self.structures_equal?(a, b)
      a_keys = a.value.keys
      b_keys = b.value.keys

      if a_keys.to_set != b_keys.to_set then
        return false
      end

      for a_key in a_keys do
        arg1 = a.value[a_key]
        arg2 = b.value[a_key]

        if arg1.primitive? && arg2.primitive? then
          return false if arg1.value != arg2.value
        elsif (arg1.primitive? && !arg2.primitive?) || (!arg1.primitive? && arg2.primitive?)
          return false
        else
          return false unless self.structures_equal?(arg1, arg2)
        end
      end

      return true
    end
    
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
