module Twigg
  module Util
  private

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
      @inflections ||= Hash.new do |hash, key|
        hash[key] = [key, plural ? plural : key + 's']
      end

      (delimit ? number_with_delimiter(count) : count.to_s) + ' ' +
        @inflections[singular][count == 1 ? 0 : 1]
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
