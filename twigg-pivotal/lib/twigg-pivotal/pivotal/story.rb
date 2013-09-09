module Twigg
  module Pivotal
    # Models the story resource in Pivotal Tracker.
    class Story < Resource
      attr_reader :pivotal_id, :current_state, :story_type, :name, :owned_by

      class << self
        # Returns an array of all open stories for the project identified by
        # `project_id`.
        def stories(project_id)
          raise ArgumentError, "'project_id' is required" unless project_id

          results = get "projects/#{project_id}/stories",
            filter: 'state:started,finished,delivered,rejected',
            fields: 'current_state,story_type,name,owned_by'

          results.map { |story| new(story) }
        end
      end

      def initialize(json)
        raise ArgumentError unless @pivotal_id    = json['id']
        raise ArgumentError unless @current_state = json['current_state']
        raise ArgumentError unless @story_type    = json['story_type']
        raise ArgumentError unless @name          = json['name']

        # optional (some stories don't have owners)
        @owned_by = json['owned_by']
      end
    end
  end
end
