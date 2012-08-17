
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

end
