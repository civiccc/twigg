module Twigg
  module Pivotal
    # This module provides an overview summary of Pivotal Tracker status.
    #
    # This is the main entry point for external callers, such as the `twigg`
    # command-line app and the Twigg web app.
    module Status
      class << self
        def status
          projects = Project.projects
          stories  = projects.flat_map(&:stories)
          stories.group_by(&:current_state)
        end
      end
    end
  end
end
