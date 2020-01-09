require "manageiq/loggers"

module Catalog
  module Api
    class Minion
      class << self
        attr_writer :logger
      end

      def self.logger
        if ENV["LOG_TO_STDOUT"].present?
          @logger ||= ManageIQ::Loggers::Base.new(STDOUT)
        else
          @logger ||= ManageIQ::Loggers::CloudWatch.new
        end

      end

      module Logging
        def logger
          Catalog::Api::Minion.logger
        end
      end
    end
  end
end
