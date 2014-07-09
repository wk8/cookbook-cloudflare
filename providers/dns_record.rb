action :create do
  load_cloudflare_cookbook_gems
  if new_resource.exists?
    Chef::Log.info "DNS record #{new_resource.complete_url} already exists, nothing more to do"
  else
    new_resource.updated_by_last_action true

    if new_resource.name_exists?
      if new_resource.shared_A_record?
        if new_resource.delete_single
          Chef::Log.info "DNS record #{new_resource.complete_url} seems to exist, but with different settings, deleting and re-creating"
        end
      else
        Chef::Log.info "DNS record with the same name as #{new_resource.complete_url} seem to exist, deleting them"
        new_resource.delete_by_name
      end
    end
    Chef::Log.info "Creating DNS record #{new_resource.complete_url}"
    new_resource.create
  end
end

action :delete do
  load_cloudflare_cookbook_gems
  if new_resource.name_exists?
    if new_resource.shared_A_record?
      if new_resource.delete_single
        new_resource.updated_by_last_action true
        Chef::Log.info "Deleting single DNS record #{new_resource.complete_url}"
      else
        Chef::Log.info "Single DNS record #{new_resource.complete_url} not found, can't delete"
      end
    else
      new_resource.updated_by_last_action true
      Chef::Log.info "Deleting all DNS records named #{new_resource.complete_url}"
      new_resource.delete_by_name
    end
  else
    Chef::Log.info "No DNS record named #{new_resource.complete_url} found, can't delete"
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
