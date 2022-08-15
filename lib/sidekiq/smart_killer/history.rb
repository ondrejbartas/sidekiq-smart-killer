module Sidekiq
  module SmartKiller
    class History

      MINUTES_STEP = 10

      COUNT = 24 * 60 / MINUTES_STEP
      def self.hostnames
        Sidekiq.redis do |conn|
          conn.smembers("smart_killer:hostnames").compact.sort
        end
      end

      def self.mem_history(hostname, count = COUNT)
        history('mem', hostname, count)
      end

      def self.cpu_history(hostname, count = COUNT)
        history('cpu', hostname, count)
      end

      def self.processes(hostname)
        Sidekiq.redis do |conn|
          conn.hgetall("smart_killer:#{hostname}:processes").each_with_object({}) do |(identity, info), out|
            out[identity] = Sidekiq.load_json(info)
          end
        end
      end

      def self.history(kind, hostname, count = COUNT)
        start_date = Time.now.utc
        keys = []
        dates = []
        stat_hash = {}
        i = 0

        while i < count
          date = start_date - (i * MINUTES_STEP) * 60
          datestr = date.strftime("%Y-%m-%dT%H:%M:00")

          kk = []
          MINUTES_STEP.times do |y|
            d = date + 60 * y
            kk << "smart_killer:#{hostname}:#{kind}_usage:#{d.strftime("%Y-%m-%dT%H:%M:00")}"
          end

          stat_hash[datestr] = Sidekiq.redis do |conn|
            values = conn.mget(kk).compact.map(&:to_f)
            if values.any?
              values.sum / values.size
            else
              -1
            end
          end
          i += 1
        end

        stat_hash
      end
    end
  end
end
