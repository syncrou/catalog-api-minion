source 'https://rubygems.org'

plugin 'bundler-inject', '~> 1.1'
require File.join(Bundler::Plugin.index.load_paths("bundler-inject")[0], "bundler-inject") rescue nil

gem "catalog-api-client", :git => "https://github.com/mkanoor/catalog-api-client-ruby.git", :branch => "master"
gem "cloudwatchlogger", "~> 0.2"
gem "concurrent-ruby"
gem "more_core_extensions"
gem "optimist"
gem "prometheus_exporter", "~> 0.4.5"
gem "rake"
gem "rest-client", ">= 1.8.0"

gem "manageiq-loggers", "~> 0.3.0"
gem "manageiq-messaging", "~> 0.1.2"

group :development, :test do
  gem "rspec"
  gem "simplecov"
  gem "webmock"
  gem "byebug"
end
