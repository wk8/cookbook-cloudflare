# -*- mode: ruby -*-
# vi: set ft=ruby :

CLOUDFLARE_EMAIL = ENV['CLOUDFLARE_EMAIL']
CLOUDFLARE_API_KEY = ENV['CLOUDFLARE_API_KEY']
CLOUDFLARE_ZONE = ENV['CLOUDFLARE_ZONE']

if !CLOUDFLARE_EMAIL || !CLOUDFLARE_API_KEY || !CLOUDFLARE_ZONE
  raise 'You must define the CLOUDFLARE_EMAIL, CLOUDFLARE_API_KEY and CLOUDFLARE_ZONE environment variables'
end

VAGRANTFILE_API_VERSION = '2'

Vagrant.require_version '>= 1.5.0'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.hostname = 'cloudflare-berkshelf'
  config.omnibus.chef_version = '11.6.0'
  config.vm.box = 'opscode_ubuntu-12.04_provisionerless'
  config.vm.box_url = 'https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box'

  config.berkshelf.enabled = true

  # we use chef-zero instead of solo if the plugin is available
  # that makes it easy to test the caching mechanism for the
  # threat_control resource
  if Vagrant.has_plugin? 'vagrant-chef-zero'
    provisioner = :chef_client
  else
    provisioner = :chef_solo
  end

  config.vm.provision provisioner do |chef|
    chef.json = {
      'cloudflare' => {
        'credentials' => {
          'email' => CLOUDFLARE_EMAIL,
          'api_key' => CLOUDFLARE_API_KEY
        },
        'threat_control' => {
          # one minute, to be able to test quickly
          'cache_duration' => 1.0 / (24.0 * 60.0)
        },
        'example_zone' => CLOUDFLARE_ZONE,
        'debug' => true
      }
    }

    chef.run_list = [
      'recipe[cloudflare::example]',
    ]
    if ENV['CLOUDFLARE_CLEANUP']
      chef.run_list << 'recipe[cloudflare::example-cleanup]'
    end
  end
end
