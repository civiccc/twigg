module Twigg
  class Commit
    attr_reader :repo, :commit, :subject, :body, :author, :date, :stat

    def initialize(options)
      raise ArgumentError unless @repo    = options[:repo]
      raise ArgumentError unless @commit  = options[:commit]
      raise ArgumentError unless @subject = options[:subject]
      raise ArgumentError unless @body    = options[:body]
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

    def eql?(other)
      other.is_a?(Commit)         &&
        other.repo    == @repo    &&
        other.commit  == @commit  &&
        other.subject == @subject &&
        other.body    == @body    &&
        other.author  == @author  &&
        other.date    == @date    &&
        other.stat    == @stat
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
