module Sidekiq
  module SmartKiller
    module WebExtension

      def self.registered(app)

        app.settings.locales << File.join(File.expand_path("..", __FILE__), "locales")

        #index page of cron jobs
        app.get '/smart-killer' do
          view_path    = File.join(File.expand_path("..", __FILE__), "views")

          @cron_jobs = Sidekiq::Cron::Job.all

          #if Slim renderer exists and sidekiq has layout.slim in views
          if defined?(Slim) && File.exists?(File.join(settings.views,"layout.slim"))
            render(:slim, File.read(File.join(view_path, "smart_killer.slim")))
          else
            render(:erb, File.read(File.join(view_path, "smart_killer.erb")))
          end
        end

        app.post "/smart-killer/action" do
          if params['identity']
            p = Sidekiq::Process.new('identity' => params['identity'])
            p.quiet! if params['quiet']
            p.stop! if params['stop']
          else
            processes.each do |pro|
              pro.quiet! if params['quiet']
              pro.stop! if params['stop']
            end
          end

          redirect "#{root_path}smart-killer"
        end


      end
    end
  end
end
