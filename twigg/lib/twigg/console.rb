module Twigg
  # A collection of useful methods for code that is running in a console.
  #
  # Functionality includes printing, process lifecycle management and
  # formatting.
  module Console
    extend self

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

    # Given `switches` (which may be either a single switch or an array of
    # switches) and an array of arguments, `args`, scans through the arguments
    # looking for the switches and the corresponding values.
    #
    # This can be used, for example, to extract the value "/etc/twiggrc" from an
    # argument list like "--verbose --debug --config /etc/twiggrc help".
    #
    # In the event that the switches appear multiple times in the list, the
    # right-most wins. If a switch is found without a corresponding option an
    # exception is raised.
    #
    # Consumes matching options (ie. deletes them from `args) and returns the
    # corresponding (rightmost) value, or `nil` in the event there is no match.
    def consume_option(switches, args)
      # consume from left to right; rightmost will win
      while index = args.find_index { |arg| Array(switches).include?(arg) }
        switch, value = args.slice!(index, 2)
        raise ArgumentError, "missing option (expected after #{switch})" unless value
      end

      value
    end
  end

  Console.public_class_method :die
end
