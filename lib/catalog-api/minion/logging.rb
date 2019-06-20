require "manageiq/loggers"

module CatalogApi
  class Minion
    class << self
      attr_writer :logger
    end

    def self.logger
      @logger ||= ManageIQ::Loggers::CloudWatch.new
    end

    module Logging
      def logger
        CatalogApi::Minion.logger
      end
    end
  end
end
