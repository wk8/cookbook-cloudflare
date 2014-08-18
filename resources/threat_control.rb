actions :whitelist, :blacklist, :remove_ip
default_action :nothing

attribute :ip, :kind_of => String, :default => node.ipaddress

def set_status status
  response = node.cloudflare_client.send status, ip
  if response['result'] != 'success'
    Chef::Application.fatal! "Unable to set threat control status to #{status} for ip #{ip} : Cloudflare's API returned #{response}"
  end
end
