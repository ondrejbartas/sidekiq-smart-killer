require 'sidekiq'
require 'sidekiq/cron'
require 'sidekiq/scheduled'

module Sidekiq
  module SmartKiller
    POLL_INTERVAL = 30
    STOP_JOB_WHEN_MEMORY_OVER = 900
    MINIMUM_RUNNING_TIME = 30

    # The Poller checks host stats
    class Poller < Sidekiq::Scheduled::Poller
      STATS_TTL = 7*24*60*60

      def enqueue
        time = Time.now.utc

        Sidekiq.redis do |conn|
          if conn.set("smart_killer:getting_stats:#{hostname}", "started", ex: poll_interval_average - 10, nx: true)
            # puts "Started process"
          else
            # puts "Already working"
            return
          end
        end

        number_of_cpus = (`uname`.strip == 'Darwin' ? `sysctl -n hw.logicalcpu_max`.strip : `nproc`.strip).to_i
        x = `ps aux`.split("\n").map{|l| l.split(/\s+/) }
        y = x[1..-1].map{|l| Hash[x[0].zip(l)]}

        total_mem_usage = y.sum{|a| a['%MEM'].to_f }
        max_cpu_usage_processes =  y.sum{|a| a['%CPU'].to_f }
        total_cpu_usage = (max_cpu_usage_processes / (number_of_cpus*100.0))*100

        stats_by_pid = y.each_with_object({}) do |a, out|
          out[a['PID']] = a
        end

        host_processes = {}
        Sidekiq::ProcessSet.new.each do |process|
          next unless process['hostname'] == hostname
          pid = process['pid']
          host_processes[pid] = {
            process: process,
            stats: stats_by_pid[pid.to_s],
            memory_in_mb: (stats_by_pid[pid.to_s] || {})['RSS'].to_i / 1024
          }
        end

        host_processes.
          select { |pid, v|
            v[:process]['busy'] == 0 &&
              v[:memory_in_mb] > STOP_JOB_WHEN_MEMORY_OVER &&
              v[:process]['started_at'] < MINIMUM_RUNNING_TIME.minutes.ago.to_i &&
              empty_queues?(v[:process]['queues'])
          }.each do |pid, v|

          puts "Stopping job #{v[:process].identity} with used memory #{v[:memory_in_mb]}MB"
          Sidekiq::Process.new('identity' => v[:process].identity).quiet!
          Sidekiq::Process.new('identity' => v[:process].identity).stop!
        end

        nowdate = Time.now.utc.strftime("%Y-%m-%dT%H:%M:00")
        Sidekiq.redis do |conn|
          conn.multi do
            conn.sadd("smart_killer:hostnames", hostname)
            mem_key = "smart_killer:#{hostname}:mem_usage:#{nowdate}"
            conn.set("#{mem_key}", total_mem_usage)
            conn.expire("#{mem_key}", STATS_TTL)

            cpu_key = "smart_killer:#{hostname}:cpu_usage:#{nowdate}"
            conn.set("#{cpu_key}", total_cpu_usage)
            conn.expire("#{cpu_key}", STATS_TTL)

            conn.del("smart_killer:#{hostname}:processes")
            host_processes.each do |pid, process|
              conn.hset("smart_killer:#{hostname}:processes", process[:process].identity, {memory_in_mb: process[:memory_in_mb], memory_percent: process[:stats]['%MEM'].to_f, cpu_percent: process[:stats]['%CPU'].to_f}.to_json)
            end
          end
        end

        {
          hostname: hostname,
          number_of_cpus: number_of_cpus,
          total_mem_usage: total_mem_usage,
          total_cpu_usage: total_cpu_usage,
          host_processes: host_processes,
        }
      rescue => ex
        # Most likely a problem with redis networking.
        # Punt and try again at the next interval
        Sidekiq.logger.error ex.message
        Sidekiq.logger.error ex.backtrace.first
        handle_exception(ex) if respond_to?(:handle_exception)
      end

      private

      def empty_queues?(queues)
        queues.all? { |queue| Sidekiq::Queue.new(queue).size == 0 }
      end

      def hostname
        @hostname ||= `hostname`.strip
      end

      def poll_interval_average
        30
      end
    end
  end
end
