action :whitelist do
  action_for_status :whitelist
end

action :blacklist do
  action_for_status :blacklist
end

action :remove_ip do
  action_for_status :remove_ip
end

private

# it's the same logic for all the actions, so let's DRY that up
def action_for_status status
  load_cloudflare_cookbook_gems
  ip = new_resource.ip

  if trust_cache? && status_from_cache(ip) == status
    Chef::Log.info "[CF] Cache says that #{ip} is already in status #{status}, nothing to do"
  else
    # we need to make the actual call to the API
    new_resource.set_status status
    Chef::Log.info "[CF] #{ip}'s threat control was succesfully set to #{status}"

    # no harm in caching even if the cache isn't used
    set_cache ip, status

    # as noted in the README, we can't know whether the status
    # really was updated with Cloudflare, so...
    new_resource.updated_by_last_action true
  end
end

# we trust the cache iff it's not disabled and we're not running chef-solo
def trust_cache?
  !node['cloudflare']['threat_control']['disable_cache'] \
    && !Chef::Config[:solo]
end

# returns the cache's status for that IP
# if the cache is stale, it removes that entry
# and returns `:none`
def status_from_cache ip
  clean_cache
  node['cloudflare']['threat_control']['status_cache'].fetch(ip)['status'].to_sym
rescue KeyError
  # not found
  :none
end

def is_stale? str_datetime
  DateTime.now > DateTime.strptime(str_datetime) + node['cloudflare']['threat_control']['cache_duration']
end

def set_cache ip, status
  node.normal['cloudflare']['threat_control']['status_cache'][ip] = {
    'datetime' => DateTime.now.strftime,
    'status' => status
  }
end

# we clean the whole cache every time we use it
# might look a tad inefficient, but keeps code simple
# and avoids lingering obsolete values
def clean_cache
  node.normal['cloudflare']['threat_control']['status_cache'].reject! { |ip, data| is_stale? data['datetime'] }
end
