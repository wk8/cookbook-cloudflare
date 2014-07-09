# -*- mode: ruby -*-
# vi: set ft=ruby :

CLOUDFLARE_EMAIL = ENV['CLOUDFLARE_EMAIL']
CLOUDFLARE_API_KEY = ENV['CLOUDFLARE_API_KEY']
CLOUDFLARE_ZONE = ENV['CLOUDFLARE_DOMAIN']

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

  config.vm.provision :chef_solo do |chef|
    chef.json = {
      'cloudflare' => {
        'credentials' => {
          'email' => CLOUDFLARE_EMAIL,
          'api_key' => CLOUDFLARE_API_KEY
        },
        'example_zone' => CLOUDFLARE_ZONE
      }
    }

    chef.run_list = [
      'recipe[cloudflare::example]',
    ]
  end
end
