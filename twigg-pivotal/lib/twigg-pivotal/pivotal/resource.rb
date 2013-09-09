require 'rest_client'
require 'json'
require 'uri'

module Twigg
  module Pivotal
    class Resource
      class << self
      private
        PIVOTAL_BASE = 'https://www.pivotaltracker.com/services/v5'

        def get(resource, paginate: true, **params)
          results = []
          offset  = paginate ? 0 : nil
          params  = default_params.merge(params)
          done    = false

          begin
            returned = 0
            url      = "#{PIVOTAL_BASE}/#{resource}"
            query    = params_to_query(paginate ? params.merge(offset: offset) : params)
            url << "?#{URI.encode query}"

            response   = RestClient.get url, headers
            json       = JSON[response]

            if paginate
              pagination = json['pagination']
              returned   = pagination['returned']
              offset     += returned

              if results.size + returned == pagination['total']
                done = true
              end
            end

            results.concat(json['data'])
          end until returned == 0 || done

          results
        end

        def default_params
          { envelope: true }
        end

        def headers
          { 'X-TrackerToken' => Config.pivotal.token }
        end

        def params_to_query(params)
          params.map { |key, value| "#{key}=#{value}" }.join('&')
        end
      end
    end
  end
end
