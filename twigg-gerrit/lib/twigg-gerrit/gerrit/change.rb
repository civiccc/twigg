module Twigg
  module Gerrit
    class Change
      class << self
        def changes
          DB[:changes].
            select(:change_id, :last_updated_on, :subject, :full_name).
            join(:accounts, account_id: :owner_account_id).
            where(status: 'n').
            order(Sequel.desc(:last_updated_on)).
            all.map do |change|
            new(change_id:       change[:change_id],
                subject:         change[:subject],
                full_name:       change[:full_name],
                last_updated_on: change[:last_updated_on])
          end
        end
      end

      attr_reader :change_id, :subject, :full_name, :last_updated_on

      def initialize(options = {})
        raise ArgumentError unless @change_id       = options[:change_id]
        raise ArgumentError unless @subject         = options[:subject]
        raise ArgumentError unless @full_name       = options[:full_name]
        raise ArgumentError unless @last_updated_on = options[:last_updated_on]
      end
    end
  end
end
