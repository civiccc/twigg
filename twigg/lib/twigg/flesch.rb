module Twigg
  # Class which computes an approximation of the Flesch Reading Ease metric for
  # a given piece of English-language text.
  #
  # @see {http://en.wikipedia.org/wiki/Flesch%E2%80%93Kincaid_readability_tests}
  class Flesch
    def initialize(string)
      @string = string
    end

    def reading_ease
      # from wikipedia:
      206.835 -
        1.015 * (total_words / total_sentences.to_f) -
        84.6  * (total_syllables / total_words.to_f)
    end

  private

    # Returns approximate count of words in the receiver.
    def total_words
      words.size
    end

    # Returns an array of "words" in the receiver. "Words" are defined as
    # strings of consecutive "word" characters (as defined by the regex
    # short-hand, `\w`).
    def words
      @words ||= @string.split(/\b/).select { |w| w.match /\w/ }
    end

    # Returns approximate total count of sentences in the receiver.
    def total_sentences
      @string.split(/\.+/).size
    end

    # Returns approximate total count of syllables in the receiever.
    def total_syllables
      words.inject(0) { |memo, word| memo + syllables(word) }
    end

    # Returns an approximate syllable count for `word`.
    #
    # Based on: {http://stackoverflow.com/questions/1271918/ruby-count-syllables}
    def syllables(word)
      # words of 3 letters or less count as 1 syllable; rare exceptions (eg.
      # "ion") are not handled
      return 1 if word.size <= 3

      # - ignore final es, ed, e (except for le)
      # - consecutive vowels count as one syllable
      word.
        downcase.
        gsub(/W+/, ' '). # suppress punctuation
        sub(/(?:[^laeiouy]es|ed|[^laeiouy]e)$/, '').
        sub(/^y/, '').
        scan(/[aeiouy]{1,2}/).
        size
    end
  end
end
