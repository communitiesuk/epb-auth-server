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

# Whitelist IP addresses that ignore throttling limit; format of the env var is
# "[{"reason":"pen testers", "ip_address": "198.51.100.111"},{...}]"
# white_listed_ips = JSON.parse(
#   ENV["WHITELISTED_IP_ADDRESSES"] || "[]",
#   ).map { |item|
#   item["ip_address"]
# }.flatten.uniq
#
# Rack::Attack.safelist do |req|
#   white_listed_ips.include? req.source_ip
# end


# Throttle requests to any endpoint if we receive more than X requests per min
# Rack::Attack.throttle("Requests Rate Limit", limit: 100, period: 1.minutes, &:source_ip)

# Block permanently banned IP addresses; the format of the env var is
# "[{"reason":"did a bad thing", "ip_address": "198.51.100.100"},{...}]"
banned_ips = JSON.parse(ENV["PERMANENTLY_BANNED_IP_ADDRESSES"] || "[]").map { |entry| entry["ip_address"] }.flatten.compact
pp "AUTH DEBUGGING BANNED IPS: #{banned_ips}"
Rack::Attack.blocklist("permanently blocked") do |req|
  pp "AUTH DEBUGGING CHECKING #{req.source_ip} IS IN #{banned_ips}"
  banned_ips.include? req.source_ip
end
