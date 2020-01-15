require "manageiq-messaging"
require "catalog/api/minion/logging"
require "catalog-api-client"
require "uri"

module Catalog
  module Api
    class Minion
      class Base
        include Logging

        def initialize(messaging_host, messaging_port)
          self.messaging_client = nil
          self.messaging_host   = messaging_host
          self.messaging_port   = messaging_port
        end

        def run
          logger.info("Starting Catalog Api Minion for #{queue_name}...")

          self.messaging_client = ManageIQ::Messaging::Client.open(messaging_client_opts)
          messaging_client.subscribe_topic(subscribe_opts) { |message| perform(message) }
        ensure
          messaging_client&.close
        end

        def perform(message)
          jobtype = message.message
          payload = message.payload
          payload_params = {:payload => payload, :message => jobtype}

          logger.info("Headers: #{message.headers}")
          logger.info("Topic: #{jobtype}: #{payload}")
          response = post_internal_notify(payload, payload_params, message.headers)
          logger.info("#{response}")
        rescue Exception => e
          logger.error "Problem performing internal api post: #{e.message}"
        end

        def queue_name
          raise NotImplementedError, "#{__method__} must be implemented in a subclass"
        end

        def persist_ref
          raise NotImplementedError, "#{__method__} must be implemented in a subclass"
        end

        def base_name
          raise NotImplementedError, "#{__method__} must be implemented in a subclass"
        end

        private

        attr_accessor :messaging_client, :messaging_host, :messaging_port, :queue_name

        def messaging_client_opts
          {
            :protocol   => :Kafka,
            :host       => messaging_host,
            :port       => messaging_port,
            :group_ref  => "catalog-minion-#{queue_name}",
            :client_ref => "catalog-minion-#{queue_name}"
          }
        end

        def subscribe_opts
          {
            :persist_ref     => persist_ref,
            :service         => queue_name,
            :session_timeout => 60 #seconds
          }
        end

        def internal_notify_url(path)
          config = ::CatalogApiClient.configure
          URI::HTTP.build(
            :host   => config.host.split(":").first,
            :port   => config.host.split(":").last,
            :path   => path
          ).to_s
        end
      end
    end
  end
end
