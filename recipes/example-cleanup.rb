# This recipe cleans up the records created by the example recipe

prefix = 'CL-CB-TEST'

%w{simple-A simple-CNAME shared-A-rec conflicting-A conflicting-CNAME}.each do |name|
  cloudflare_dns_record "#{prefix}-#{name}" do
    zone node['cloudflare']['example_zone']
    action :delete
  end
end

['172.20.126.126', '172.20.127.127'].each do |ip|
  cloudflare_threat_control "remove-threat-control-#{ip}" do
    ip ip
    action :remove_ip
  end
end
