module Twigg
  module Pivotal
    # Models the project resource in Pivotal Tracker.
    class Project < Resource
      attr_reader :pivotal_id, :name

      class << self
        # Returns an array of all projects accessible with the configured access
        # token.
        def projects
          results = get 'projects', fields: 'name', paginate: false
          results.map { |project| new(project) }
        end
      end

      def initialize(json)
        raise ArgumentError unless @pivotal_id = json['id']
        raise ArgumentError unless @name       = json['name']
      end

      # Returns the open stories for this project.
      def stories
        Story.stories(@pivotal_id)
      end
    end
  end
end
