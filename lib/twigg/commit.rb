module Twigg
  class Commit
    attr_reader :repo, :commit, :subject, :author, :date, :stat

    def initialize(options)
      raise ArgumentError unless @repo    = options[:repo]
      raise ArgumentError unless @commit  = options[:commit]
      raise ArgumentError unless @subject = options[:subject]
      raise ArgumentError unless @author  = options[:author]
      raise ArgumentError unless @date    = options[:date]
      raise ArgumentError unless @stat    = options[:stat]
    end

    def link
      if Config.github.organization
        "https://github.com/#{Config.github.organization}/#{repo.name}/commit/#{commit}"
      end
    end

    def author_names
      @author.split(/\+|&|,|\band\b/).map(&:strip)
    end

    def inspect
      "repo: #{@repo.name}\n" +
        "commit: #{@commit}\n" +
        "subject: #{@subject}\n" +
        "author: #{@author}\n" +
        "stat: +#{@stat[:additions]}, -#{@stat[:deletions]}"
    end
  end
end
