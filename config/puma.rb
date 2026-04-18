# config/puma.rb
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

rails_env = ENV.fetch("RAILS_ENV") { "production" }
environment rails_env

app_dir = File.expand_path("..", __dir__)
shared_dir = "#{app_dir}/tmp"

# ── Unix socket (same pattern as eloy-back-timer) ──
bind "unix://#{shared_dir}/sockets/puma.sock"

# ── Logging ──
stdout_redirect "#{app_dir}/log/puma.stdout.log",
                "#{app_dir}/log/puma.stderr.log",
                true

# ── PID file ──
pidfile "#{shared_dir}/pids/puma.pid"
state_path "#{shared_dir}/pids/puma.state"

# ── Workers (set to 2 for a 4GB Linode) ──
workers ENV.fetch("WEB_CONCURRENCY") { 2 }
preload_app!

on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end