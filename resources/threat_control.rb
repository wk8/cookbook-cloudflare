actions :whitelist, :blacklist, :remove_ip
default_action :nothing

attribute :ip, :kind_of => String, :default => node.ipaddress

SAFETY_INTERVAL = 1  # day(s), interval during which the node's attributes caching remains valid

require 'date'


def whitelisted?
  return cache_status?('whitelisted')
end

def blacklisted?
  return cache_status?('blacklisted')
end

def removed?
  return cache_status?('removed')
end

# Return true if the cache is not expired (<1d) and indicates said IP has a status matching the one given
def cache_status? status_to_check
  status_cache = node[:cloudflare][:threat_control][ip]

  if !(status_cache.nil? || status_cache.empty?)
    if DateTime.now() < status_cache[:updated_at] + SAFETY_INTERVAL
      Chef::Log.info "[CF] Local threat control cache for #{ip} was set on #{status_cache[:updated_at]} and is '#{status_cache[:status]}'"
      return status_cache[:status] == status_to_check
    end
  end

  return false
end

def whitelist
  node.cloudflare_client.whitelist(ip)
  update_whitelist_status_cache('whitelisted')
  Chef::Log.info "[CF] Whitelisted IP #{ip}"
end

def blacklist
  node.cloudflare_client.blacklist(ip)
  update_whitelist_status_cache('blacklisted')
  Chef::Log.info "[CF] Blacklisted IP #{ip}"
end

def remove_ip
  node.cloudflare_client.remove_ip(ip)
  update_whitelist_status_cache('removed')
  Chef::Log.info "[CF] Removed IP #{ip} from threat control"
end


private

def update_whitelist_status_cache new_status
  node.normal[:cloudflare][:threat_control][ip] = {
    :status => new_status,
    :updated_at => DateTime.now()
  }
end
