require "catalog-api-client"
require "rest-client"
require "catalog/api/minion/base"

module Catalog
  module Api
    class Minion
      class Approval < Base
        include Logging

        def base_name
          "Catalog API Approval Minion"
        end

        def queue_name
          "platform.approval".freeze
        end

        def persist_ref
          "catalog-api-approval-minion".freeze
        end

        private

        def post_internal_notify(payload, payload_params)
          RestClient.post(internal_notify_url(payload['request_id']), payload_params, identity_headers(persist_ref))
        end

        def internal_notify_url(request_id)
          super("/internal/v1.0/notify/approval_request/#{request_id}")
        end
      end
    end
  end
end
