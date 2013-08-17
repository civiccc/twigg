module Twigg
  module Gerrit
    # Stats for "@" tags.
    class Tag
      class << self
        # Returns a hash of "@" tag stats for the last `days` days.
        #
        # Within the hash there are 3 key-value pairs:
        #
        #   - :from: a hash of "from" authors; each author has its own hash of
        #      tags and counts
        #   - :to: a hash of "to" authors; again with a subhash for each author
        #   - :global: a hash of all tags and their counts
        #
        def stats(days: 7)
          {
            from:   Hash.new { |h, k| h[k] = Hash.new(0) },
            to:     Hash.new { |h, k| h[k] = Hash.new(0) },
            global: Hash.new(0),
          }.tap do |stats|
            (change_messages(days) + comment_messages(days)).each do |result|
              tags_from_result(result[:message]).each do |tag, count|
                [
                  stats[:from][result[:from_full_name]],
                  stats[:to][result[:to_full_name]],
                  stats[:global],
                ].each do |hash|
                  hash[tag] += count
                end
              end
            end
          end
        end

      private

        # Return all comment messages containing "@" tags within the last `days`
        # days.
        def comment_messages(days)
          DB[<<-SQL, days].all
            SELECT message,
                   from_accounts.full_name AS from_full_name,
                   to_accounts.full_name AS to_full_name
              FROM patch_comments
              JOIN accounts AS from_accounts
                ON patch_comments.author_id = from_accounts.account_id
              JOIN changes
                ON patch_comments.change_id = changes.change_id
              JOIN accounts AS to_accounts
                ON changes.owner_account_id = to_accounts.account_id
             WHERE written_on > DATE_SUB(NOW(), INTERVAL ? DAY)
               AND message like '%@%'
          SQL
        end

        # Return all change messages containing "@" tags within the last `days`
        # days.
        def change_messages(days)
          DB[<<-SQL, days].all
            SELECT message,
                   from_accounts.full_name AS from_full_name,
                   to_accounts.full_name AS to_full_name
              FROM change_messages
              JOIN accounts AS from_accounts
                ON change_messages.author_id = from_accounts.account_id
              JOIN changes
                ON change_messages.change_id = changes.change_id
              JOIN accounts AS to_accounts
                ON changes.owner_account_id = to_accounts.account_id
             WHERE written_on > DATE_SUB(NOW(), INTERVAL ? DAY)
               AND message like '%@%'
          SQL
        end

        # Given a string, `text`, extract "@" tags.
        #
        # Returns a hash where the keys are tag names and the values are counts
        # that indicate the number of times a tag appeared in `text`.
        def tags_from_result(text)
          tags = text.scan(/(?<=@)\w+/).map(&:downcase)

          tags.each_with_object(Hash.new(0)) { |tag, memo| memo[tag] += 1 }
        end
      end
    end
  end
end
