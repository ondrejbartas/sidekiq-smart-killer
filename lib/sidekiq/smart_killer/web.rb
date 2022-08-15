require "sidekiq/smart_killer/web_extension"
require "sidekiq/smart_killer/history"

if defined?(Sidekiq::Web)
  Sidekiq::Web.register Sidekiq::SmartKiller::WebExtension

  if Sidekiq::Web.tabs.is_a?(Array)
    # For sidekiq < 2.5
    Sidekiq::Web.tabs << "smart-killer"
  else
    Sidekiq::Web.tabs["Smart Killer"] = "smart-killer"
  end
end
