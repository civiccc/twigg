module Twigg
  module Util
    extend self

    def number_with_delimiter(integer)
      # Regex based on one in `ActiveSupport::NumberHelper#number_to_delimited`;
      # this method is simpler because it only needs to handle integers.
      integer.to_s.tap do |string|
        string.gsub!(/(\d)(?=(\d{3})+(?!\d))/, '\\1,')
      end
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
