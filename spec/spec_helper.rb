require 'russian_central_bank'
require 'webmock/rspec'
require 'support/helpers'


RSpec.configure do |config|
  config.color_enabled = true
  config.tty = true

  config.order = :random
end
