# If set to true, will perform all possible checks on your credentials and so on
# You most likely want that switched to `false' when you're done setting up your
# cookbook! That way we'll make as few calls to Cloudflare API as possible
default['cloudflare']['debug'] = false

# If set to true, we'll check your credentials are valid before carrying on
default['cloudflare']['check_credentials'] = node['cloudflare']['debug']
# If set to true, we'll check the specified zone exists before trying to create
# or delete new records in it
default['cloudflare']['check_zone'] = node['cloudflare']['debug']

# Set that attribute below to true if you decide to check your records by
# querying a DNS server instead of Cloudflare directly (can be useful to avoid
# making too many requests to Cloudflare if you have a number of servers
default['cloudflare']['check_with_DNS'] = true
# If you set the attribute above to true, that's the DNS server we're going
# to ask - defaults to Cloudflare's main public DNS server
default['cloudflare']['DNS_server'] = 'ns.cloudflare.com'


# Interval during which the threat control caching in node's attributes remains valid
# In days, as a float
default['cloudflare']['threat_control']['cache_duration'] = 1.0
# If set to true, we won't care about the cached information - be aware that will
# result in quite a lot of API calls (one per resource and per chef run)
default['cloudflare']['threat_control']['disable_cache'] = false

# Do not edit this manually, this is where this cookbook caches the threat-control
# statuses
# For the record, it maps IPs to a hash with the 'status' and 'datetime' keys
default['cloudflare']['threat_control']['status_cache'] = {}
