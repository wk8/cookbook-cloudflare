action :create do
    load_cloudflare_cookbook_gems
    if new_resource.exists?
        Chef::Log.info "DNS record #{new_resource} already exists, nothing more to do"
    else
        if new_resource.name_exists? and new_resource.exclusive?
            Chef::Log.info "DNS record #{new_resource} seems to for different settings or content, deleting and re-creating"
            new_resource.delete_all_with_name
        else
            Chef::Log.info "DNS record #{new_resource} seems to exist with correct content, but with different settings, deleting and re-creating"
            new_resource.delete
        end
        Chef::Log.info "Creating DNS record #{new_resource}"
        new_resource.create
    end
end

action :delete do
    load_cloudflare_cookbook_gems
    if new_resource.name_exists?
        Chef::Log.info "Deleting DNS record #{new_resource}"
        new_resource.delete
    else
        Chef::Log.info "DNS record #{new_resource} not found, can't delete"
    end
end


private

# this needs to be done at run time, not compile time
def load_cloudflare_cookbook_gems
    return if defined? @@cloudflare_cookbook_gems_loaded
    chef_gem 'cloudflare' do
        action :install
        version '2.0.1'
    end
    require 'resolv'
    require 'cloudflare'
    @@cloudflare_cookbook_gems_loaded = true
end
