# This recipe cleans up the records created by the example recipe

prefix = 'CL-CB-TEST'

%w{simple-A simple-CNAME shared-A-rec conflicting-A conflicting-CNAME}.each do |name|
  cloudflare_dns_record "#{prefix}-#{name}" do
    zone node['cloudflare']['example_zone']
    action :delete
  end
end
