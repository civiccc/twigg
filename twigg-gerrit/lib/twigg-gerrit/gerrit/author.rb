module Twigg
  module Gerrit
    # Author-centric stats for activity on Gerrit (commenting, reviewing) and
    # "quality" (attracting comments, pushing multiple patch sets).
    class Author
      class << self
        # Returns a Hash of stats where the keys are author names and the
        # values are hashes containing stats (keys: stat labels, values:
        # counts).
        def stats(days: 7)
          Hash.new { |h, k| h[k] = {} }.tap do |hash|
            {
              comments_posted:         comments_posted(days),
              comments_received:       comments_received(days),
              recently_active_changes: recently_active_changes(days),
              revisions_pushed:        revisions_pushed(days),
              scores_assigned:         scores_assigned(days),
            }.each do |label, stats|
              stats.each do |author_stats|
                hash[author_stats[:full_name]][label] = author_stats[:count]
              end
            end
          end
        end

      private

        def comments_posted(days)
          DB[:patch_comments].
            select_group(:full_name).
            select_append { count(1).as(:count) }.
            join(:accounts, account_id: :author_id).
            where('written_on > DATE_SUB(NOW(), INTERVAL ? DAY)', days).
            order(Sequel.desc(:count)).
            all
        end

        def scores_assigned(days)
          DB[:change_messages].
            select_group(:full_name).
            select_append { count(1).as(:count) }.
            join(:accounts, account_id: :author_id).
            where('written_on > DATE_SUB(NOW(), INTERVAL ? DAY)', days).
            order(Sequel.desc(:count)).
            all
        end

        def revisions_pushed(days)
          DB[:patch_sets].
            select_group(:full_name).
            select_append { count(1).as(:count) }.
            join(:changes, change_id: :change_id).
            join(:accounts, account_id: :owner_account_id).
            where('last_updated_on > DATE_SUB(NOW(), INTERVAL ? DAY)', days).
            order(Sequel.desc(:count)).
            all
        end

        def comments_received(days)
          DB[:patch_comments].
            select_group(:full_name).
            select_append { count(1).as(:count) }.
            join(:changes, change_id: :change_id).
            join(:accounts, account_id: :owner_account_id).
            where('last_updated_on > DATE_SUB(NOW(), INTERVAL ? DAY)', days).
            where('author_id != owner_account_id').
            order(Sequel.desc(:count)).
            all
        end

        def recently_active_changes(days)
          DB[:changes].
            select_group(:full_name).
            select_append { count(1).as(:count) }.
            join(:accounts, account_id: :owner_account_id).
            where('last_updated_on > DATE_SUB(NOW(), INTERVAL ? DAY)', days).
            order(Sequel.desc(:count)).
            all
        end
      end
    end
  end
end
