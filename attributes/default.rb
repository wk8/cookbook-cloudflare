# If set to true, we'll check your credentials are valid before carrying on
default['cloudflare']['check_credentials'] = true
# If set to true, we'll check the specified zone exists before trying to create
# or delete new records in it
default['cloudflare']['check_zone'] = true

# Set that attribute below to true if you decide to check your records by
# querying a DNS server instead of Cloudflare directly (can be useful to avoid
# making too many requests to Cloudflare if you have a number of servers
default['cloudflare']['check_with_DNS'] = false
# If you set the attribute above to true, that's the DNS server we're going
# to ask - defaults to Cloudflare's main public DNS server
default['cloudflare']['DNS_server'] = 'ns.cloudflare.com'
