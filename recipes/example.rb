# This example recipe shows how to use the cloudflare_dns_record LWRP

cloudflare_dns_record 'example' do
  zone node['cloudflare']['example_zone']
end
