
module Helper

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

  class URI
    class << self

      def to_qs(hash)
        hash.map do |key, value|
          key + "=" + value
        end.join('&')
      end

    end
  end
end
