require 'catalog-api-client'
require "rest-client"
require "catalog/api/minion/base"
require "uri"

module Catalog
  module Api
    class Minion
      class Order < Base
        include Logging

        def base_name
          "Catalog API Order Minion"
        end

        def queue_name
          "platform.topological-inventory.task-output-stream".freeze
        end

        def persist_ref
          "catalog-api-order-minion".freeze
        end

        def perform(message)
          jobtype = message.message
          payload = message.payload
          payload_params = {:payload =>  message.payload, :message => jobtype}

          logger.info("#{jobtype}: #{payload}")
          response = post_internal_notify(payload, payload_params)
          logger.info("#{response}")
        end

        private

        def post_internal_notify(payload, payload_params)
          RestClient.post(internal_notify_url(payload['task_id']), payload_params, identity_headers(persist_ref))
        end

        def internal_notify_url(task_id)
          config = ::CatalogApiClient.configure
          URI::HTTP.build(
            :host   => config.host.split(":").first,
            :port   => config.host.split(":").last,
            :path   => "/internal/v1.0/notify/order_item/#{task_id}"
          ).to_s
        end
      end
    end
  end
end
