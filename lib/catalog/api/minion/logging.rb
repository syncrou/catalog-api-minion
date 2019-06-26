require "manageiq/loggers"

module Catalog
  module Api
    class Minion
      class << self
        attr_writer :logger
      end

      def self.logger
        @logger ||= ManageIQ::Loggers::CloudWatch.new
      end

      module Logging
        def logger
          Catalog::Api::Minion.logger
        end
      end
    end
  end
end
