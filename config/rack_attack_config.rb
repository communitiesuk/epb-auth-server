# frozen_string_literal: true

REDIS_DB_NUMBER_FOR_AUTH_SERVER = 1 # Frontend uses default DB 0; use 1 for Auth
environment = ENV["STAGE"]

if %w[development test].include? environment
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  Rack::Attack.enabled = false
else
  redis_url = Helper::RedisConfigurationReader.read_configuration_url("mhclg-epb-redis-ratelimit-#{environment}")
  Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(url: redis_url, db: REDIS_DB_NUMBER_FOR_AUTH_SERVER)
end

# Monkey patch to have access to the first client IP in X_FORWARDED_FOR header
class Rack::Attack::Request < ::Rack::Request
  def source_ip
    if (forwarded_for = self.forwarded_for) && !forwarded_for.empty?
      return forwarded_for.first
    end

    ip
  end
end

# Block permanently banned IP addresses; the format of the env var is
# "[{"reason":"did a bad thing", "ip_address": "198.51.100.100"},{...}]"
banned_ips = JSON.parse(ENV["PERMANENTLY_BANNED_IP_ADDRESSES"] || "[]").map { |entry| entry["ip_address"] }.flatten.compact
Rack::Attack.blocklist("permanently blocked") do |req|
  banned_ips.include? req.source_ip
end
