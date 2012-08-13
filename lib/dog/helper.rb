#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  module Helper

    def self.singularize(word)
      return word[0...-1]
    end

    def self.pluralize(word)
      return "#{word}s"
    end

    def self.unique_number
      @unique ||= 0
      @unique += 1
      return @unique
    end

  end
end