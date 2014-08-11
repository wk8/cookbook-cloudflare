action :whitelist do
  load_cloudflare_cookbook_gems
  if new_resource.whitelisted?
    Chef::Log.info "[CF] IP #{new_resource.ip} is already whitelisted, nothing to do"
  else
    new_resource.whitelist
    new_resource.updated_by_last_action true
  end
end

action :blacklist do
  load_cloudflare_cookbook_gems
  if new_resource.blacklisted?
    Chef::Log.info "[CF] IP #{new_resource.ip} is already blacklisted, nothing to do"
  else
    new_resource.blacklist
    new_resource.updated_by_last_action true
  end
end

action :remove_ip do
  load_cloudflare_cookbook_gems
  if new_resource.removed?
    Chef::Log.info "[CF] IP #{new_resource.ip} is already removed from CloudFlare threat control, nothing to do"
  else
    new_resource.remove_ip
    new_resource.updated_by_last_action true
  end
end
