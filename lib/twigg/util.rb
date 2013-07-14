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
  end
end
