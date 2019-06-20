require 'catalog-api-client'
require "rest-client"
require "catalog-api/minion/base"
require "uri"

module CatalogApi
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

      def perform(message)
        jobtype = message.message
        payload = message.payload
        payload_params = { :payload =>  message.payload, :message => jobtype }

        logger.info("#{jobtype}: #{payload}")
        response = post_internal_notify(payload, payload_params)
        logger.info("#{response}")
      end


      def post_internal_notify(payload, payload_params)
        RestClient::Request.new(:method => :post,
                                :headers => identity_headers(persist_ref),
                                :url => internal_notify_url(payload['request_id']),
                                :payload => payload_params).execute
      end

      def internal_notify_url(request_id)
        config = ::CatalogApiClient.configure
        URI::HTTP.build(
          :host   => config.host.split(":").first,
          :port   => config.host.split(":").last,
          :path   => "/internal/v1.0/notify/ApprovalRequest/#{request_id}"
        ).to_s
      end
    end
  end
end
