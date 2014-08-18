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
