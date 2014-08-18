# This example recipe shows how to use the cloudflare_dns_record LWRP
# Use the example_cleanup recipe to remove records created by this recipe

# we prefix all the records to avoid collisions with actual records
prefix = 'CL-CB-TEST'

# A simple A record
cloudflare_dns_record "#{prefix}-simple-A" do
  zone node['cloudflare']['example_zone']
end

# A simple CNAME record
cloudflare_dns_record "#{prefix}-simple-CNAME" do
  zone node['cloudflare']['example_zone']
  type 'CNAME'
  content 'google.com'
end

# 3 A records with the same name
shared_A_rec_name = "#{prefix}-shared-A-rec"

cloudflare_dns_record 'shared_A_rec_1' do
  zone node['cloudflare']['example_zone']
  content '1.2.3.4'
  shared_A_record true
  record_name shared_A_rec_name
end

cloudflare_dns_record 'shared_A_rec_2' do
  zone node['cloudflare']['example_zone']
  content '5.6.7.8'
  shared_A_record true
  record_name shared_A_rec_name
end

cloudflare_dns_record 'shared_A_rec_3' do
  zone node['cloudflare']['example_zone']
  content '9.10.11.12'
  shared_A_record true
  record_name shared_A_rec_name
end

# and then we delete the 2nd one only
cloudflare_dns_record 'shared_A_rec_2_delete' do
  zone node['cloudflare']['example_zone']
  content '5.6.7.8'
  shared_A_record true
  record_name shared_A_rec_name
  action :delete
end

# Test that a simple A record will get overwritten if shared_A_record is not set to true
cloudflare_dns_record 'A-to-be-overwritten' do
  zone node['cloudflare']['example_zone']
  content '8.8.8.8'
  record_name "#{prefix}-conflicting-A"
end

cloudflare_dns_record 'A-overwriting' do
  zone node['cloudflare']['example_zone']
  content '8.8.4.4'
  record_name "#{prefix}-conflicting-A"
end

# and same, for CNAME records
cloudflare_dns_record 'CNAME-to-be-overwritten' do
  zone node['cloudflare']['example_zone']
  type 'CNAME'
  content 'puppetlabs.com'
  record_name "#{prefix}-conflicting-CNAME"
end

cloudflare_dns_record 'CNAME-overwriting' do
  zone node['cloudflare']['example_zone']
  type 'CNAME'
  content 'getchef.com'
  record_name "#{prefix}-conflicting-CNAME"
end

##
## Threat control testing
##

cloudflare_threat_control 'whitelist_test_server_a' do
  ip '172.20.126.126'
  action :whitelist
end

cloudflare_threat_control 'blacklist_test_server_b' do
  ip '172.20.127.127'
  action :blacklist
end
