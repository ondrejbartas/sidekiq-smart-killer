require "sidekiq/smart_killer/poller"
require "sidekiq/smart_killer/launcher"

module Sidekiq
  module SmartKiller
    Redis.respond_to?(:exists_returns_integer) && Redis.exists_returns_integer =  false
  end
end
