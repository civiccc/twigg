module Twigg
  module Util
    class << self
      def inflections
        @inflections ||= {}
      end
    end

  private

    # Returns the age of `time` relative to now in hours (for short intervals)
    # or days (for intervals longer than 24 hours).
    def age(time)
      delta = Time.now - time
      return 'future' if delta < 0
      hours = (delta / (60 * 60)).to_i
      days = hours / 24
      (hours > 24 ? "#{pluralize days, 'day'}" : "#{pluralize hours, 'hour'}") +
        ' ago'
    end

    def number_with_delimiter(integer)
      # Regex based on one in `ActiveSupport::NumberHelper#number_to_delimited`;
      # this method is simpler because it only needs to handle integers.
      integer.to_s.tap do |string|
        string.gsub!(/(\d)(?=(\d{3})+(?!\d))/, '\\1,')
      end
    end

    # Dumb implementation of a Rails-style `#pluralize` helper.
    #
    # As a default, it pluralizes by adding an "s" to the singular form, and
    # will use `#number_with_delimiter` to insert delimiters, unless passed
    # `delimit: false`.
    #
    # If you pass a plural inflection, it is remembered for subsequent calls.
    #
    # Example:
    #
    #   pluralize(1, 'octopus', 'octopi')          # => "1 octopus"
    #   pluralize(2, 'octopus')                    # => "2 octopi"
    #   pluralize(1_200, 'commit')                 # => "1,200 commits"
    #   pluralize(1_200, 'commit', delimit: false) # => "1200 commits"
    #
    def pluralize(count, singular, plural = nil, delimit: true)
      inflections = ::Twigg::Util.inflections
      number      = delimit ? number_with_delimiter(count) : count.to_s

      if plural
        inflections[singular] ||= plural
      else
        plural = inflections[singular] || (singular + 's')
      end

      "#{number} #{count == 1 ? singular : plural}"
    end

    # Returns a per-repo breakdown (repo names, commit counts) of commits in
    # `commit_set`.
    #
    # Returns HTML output by default, or plain-text when `html` is `false`.
    def breakdown(commit_set, html: true)
      commit_set.count_by_repo.map do |data|
        if html && (link = data[:repo].link)
          name = %{<a href="#{link}">#{data[:repo].name}</a>}
        else
          name = data[:repo].name
        end

        if html
          "<i>#{name}:</i> <b>#{number_with_delimiter data[:count]}</b>"
        else
          "#{name}: #{number_with_delimiter data[:count]}"
        end
      end.join(', ')
    end
  end
end
