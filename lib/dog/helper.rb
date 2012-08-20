#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog

  class Language
    class << self

      def singularize(word)
        return word[0...-1]
      end

      def pluralize(word)
        return "#{word}s"
      end
    end
  end

  module Helper

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
