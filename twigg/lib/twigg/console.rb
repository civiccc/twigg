module Twigg
  # A collection of useful methods for code that is running in a console.
  #
  # Functionality includes printing, process lifecycle management and
  # formatting.
  module Console
  private
    # Print `msgs` to standard error
    def stderr(*msgs)
      STDERR.puts(*msgs)
    end

    # Exit with an exit code of 1, printing the optional `msg`, prefixed with
    # "error: ", to standard error if present
    def die(msg = nil)
      error(msg) if msg
      exit 1
    end

    # Print `msg` to the standard error, prefixed with "error: "
    def error(msg)
      stderr("error: #{msg}")
    end

    # Print `msg` to the standard error, prefixed with "warning: "
    def warn(msg)
      stderr "warning: #{msg}"
    end

    # Given a "heredoc" `doc`, find the non-empty line with the smallest indent,
    # and strip that amount of whitespace from the beginning of each line.
    #
    # This allows us to write nicely indented copy that sits well with the
    # surrounding code, irrespective of the level of indentation of the code,
    # without emitting excessive whitespace to the user at runtime.
    def strip_heredoc(doc)
      indent = doc.scan(/^[ \t]*(?=\S)/).map(&:size).min || 0
      doc.gsub(/^[ \t]{#{indent}}/, '')
    end
  end
end
