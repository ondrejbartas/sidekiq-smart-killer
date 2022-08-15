# require cron poller
require 'sidekiq/smart_killer/poller'

# For SmartKiller we need to add some methods to Launcher
# so look at the code bellow.
#
# we are creating new smart killer poller instance and
# adding start and stop commands to launcher
module Sidekiq
  module SmartKiller
    module Launcher
      # Add cron poller to launcher
      attr_reader :smart_killer_poller

      # add cron poller and execute normal initialize of Sidekiq launcher
      def initialize(options)
        @smart_killer_poller = Sidekiq::SmartKiller::Poller.new
        super(options)
      end

      # execute normal run of launcher and run cron poller
      def run
        super
        smart_killer_poller.start
      end

      # execute normal quiet of launcher and quiet cron poller
      def quiet
        smart_killer_poller.terminate
        super
      end

      # execute normal stop of launcher and stop cron poller
      def stop
        smart_killer_poller.terminate
        super
      end
    end
  end
end

Sidekiq.configure_server do
  # require  Sidekiq original launcher
  require 'sidekiq/launcher'
  puts "START"
  ::Sidekiq::Launcher.prepend(Sidekiq::SmartKiller::Launcher)
end
