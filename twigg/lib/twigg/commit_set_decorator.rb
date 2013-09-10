module Twigg
  class CommitSetDecorator < Decorator
    include Util # for `number_with_delimiter`

    # Returns a per-repo breakdown (repo names, commit counts) of commits in
    # the decorated {CommitSet}.
    #
    # Returns HTML output by default, or plain-text when `html` is `false`.
    def breakdown(html: true)
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

  private

    def commit_set
      @decorated
    end
  end
end
