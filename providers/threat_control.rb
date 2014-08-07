action :whitelist do
  load_cloudflare_cookbook_gems
  if new_resource.whitelisted?
    Chef::Log.info "[CF] IP #{new_resource.ip} is already whitelisted, ignoring"
  else
    new_resource.whitelist
  end
end

action :blacklist do
  load_cloudflare_cookbook_gems
  if new_resource.blacklisted?
    Chef::Log.info "[CF] IP #{new_resource.ip} is already blacklisted, ignoring"
  else
    new_resource.blacklist
  end
end

action :remove_ip do
  load_cloudflare_cookbook_gems
  if new_resource.removed?
    Chef::Log.info "[CF] IP #{new_resource.ip} is already removed from CloudFlare threat control, ignoring"
  else
    new_resource.remove_ip
  end
end

private

# this needs to be done at run time, not compile time
def load_cloudflare_cookbook_gems
  return if defined? @@cloudflare_cookbook_gems_loaded

  chef_gem 'cloudflare' do
    action :nothing
    version '2.0.1'
  end.run_action(:install, :immediately)
  require 'resolv'
  require 'cloudflare'
  @@cloudflare_cookbook_gems_loaded = true
end
