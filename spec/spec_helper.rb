require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter 'main.rb'
end

Dir[Dir.pwd + "../app/*.rb"].each { |f| require f }
require_relative '../app/codebreaker_app.rb'
require 'rack/test'

RSpec.configure do |config|
  include Rack::Test::Methods

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
