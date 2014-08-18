# This recipe cleans up the records created by the example recipe

prefix = 'CL-CB-TEST'

%w{simple-A simple-CNAME shared-A-rec conflicting-A conflicting-CNAME}.each do |name|
  cloudflare_dns_record "#{prefix}-#{name}" do
    zone node['cloudflare']['example_zone']
    action :delete
  end
end

cloudflare_threat_control 'remove_ip_test_server_a' do
  ip '172.20.126.126'
  action :remove_ip
end

cloudflare_threat_control 'remove_ip_test_server_b' do
  ip '172.20.127.127'
  action :remove_ip
end
