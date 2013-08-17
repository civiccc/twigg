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

    def filtered_commit_message
      @filtered_commit_message ||= @body.reject do |line|
        line =~ /^[a-z-]+: /i # filter out Change-Id:, Signed-off-by: etc
      end.concat([@subject]).join("\n").chomp
    end

    def flesch_reading_ease
      @flesch_reading_ease ||= Flesch.new(filtered_commit_message).reading_ease
    end

    # Return the length of the commit message in lines.
    def russianness
      filtered_commit_message.lines.count
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
