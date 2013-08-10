module Twigg
  class Team
    # Catch-all team name for authors who aren't assigned to a particular team.
    OTHER_TEAM_NAME = 'Other'

    class << self
      # Returns a hash where the keys are author names and the values are team
      # names.
      #
      # As there is only one value per key, an author must be in one team only;
      # if the author is assigned to multiple teams, this method will pick the
      # first team the author is assigned to as his or her team.
      def author_to_team_map
        Config.
          teams.
          each_pair.
          each_with_object(Hash.new(OTHER_TEAM_NAME)) do |(team, members), map|
          members.each do |member|
            map[member] = team.to_s unless map.has_key?(member)
          end
        end
      end
    end
  end
end
