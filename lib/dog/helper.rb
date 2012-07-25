
module Helper

  def self.singularize(word)
    return word[0...-1]
  end

  def self.pluralize(word)
    return "#{word}s"
  end

end
