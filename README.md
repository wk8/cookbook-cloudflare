Description
===========

This Chef! cookbook defines one LWRP that you can easily use in your own cookbook to create and delete Cloudflare DNS records.

It is built on top of B4k3r's Ruby wrapper for the Cloudflare API. (https://github.com/B4k3r/cloudflare)

Requirements
============

Requires Chef-client version 11.x or later.

Attributes
==========

To be able to use the `clouflare_dns_record` resource, you must define two nodes attributes: `['cloudflare']['credentials']['email']` and `['cloudflare']['credentials']['api_key']`.

I strongly recommend storing your Cloudflare credentials in an encrypted data bag, and then decrypting them in your own cookbook. 

There also are a number of optional node attributes:

* `['cloudflare']['debug']`: used to defined other default attributes (see below - defaults to `false`); basically, you might want to turn that to true when setting up your cookbook, but **be sure to turn that back to `false` when running this cookbook on your actual servers to avoid hitting Cloudflare's API thresholds**
* `['cloudflare']['check_credentials']`: whether to check your Cloudflare credentials before attempting any API call (defaults to `node['cloudflare']['debug']`)
* `['cloudflare']['check_zone']`: whether to check if the specified DNS zone(s) exist(s) on your Cloudflare account before trying to add or delete records (defaults to `node['cloudflare']['debug']`)
* `['cloudflare']['check_with_DNS']`: whether to try checking your records' existence against a DNS server rather than querying the Cloudflare API (will still query the Cloudflare API if the DNS server does not return what's expected - defaults to `true`)
* `['cloudflare']['DNS_server']`: if you use the `check_with_DNS` option, that is the DNS server that will be queried (defaults to `ns.cloudflare.com`, which is Cloudflare's main public DNS server)

Those attributes come in especially handy if you have a number of servers and get throttled by Cloudflare's API limits.

Usage
=====

To use the `clouflare_dns_record` resource in your own cookbook, simply tell Chef! that your cookbook depends on this one, by adding `depends 'cloudflare'` in your `metadata.rb` file.

`clouflare_dns_record` Resource
-------------------------------

This resource defines the following attributes (they're all `String`s unless otherwise specified):

* `name` (required): the name of the Chef! resource. It is also the name of the DNS record, unless the `record_name` attribute is set
* `record_name` (optional): as said above, you can set that attribute to override the name of the DNS record (useful for registering several records with the same name - e.g. in different zones - during the same Chef! run)
* `zone` (required): the zone of the DNS record
* `content` (optional - defaults to `node.ipaddress`): the content of the DNS record
* `type` (one of `'A'` or `'CNAME'` - defaults to `'A'`): the type of the DNS record. Please let me know if you'd like other record types supported
* `ttl` (must be a `Fixnum` - defaults to `1`, which, according to Cloudflare's doc, means 'automatic'): the ttl of the DNS record
* `shared_A_record` (boolean - optional, defaults to `false`): set that to `true` if you want to have several A records with the same name (aka DNS load balancing). Also works for deleting a single A record when several share the same name. Disclaimer: IMHO, that's [pretty bad practice](http://bitplex.me/2008/09/why-round-robin-dns-is-bad.html). This attribute is totally ignored for CNAME records.

For instance, the following code in your cookbook's recipe would create an `A` DNS record `server_name.example.com` pointing to `1.2.3.4` with an automatic TTL:

    cloudflare_dns_record 'server_name' do
        zone 'example.com'
        content '1.2.3.4'
    end

The `clouflare_dns_record` resource defines two different actions: `:create` and `:delete` (pretty self-explanatory); `:create` is the default one.

Another example:

    cloudflare_dns_record 'resource_name' do
        zone 'example.com'
        record_name 'server_name'
        action :delete
    end

would delete the `server_name.example.com` record from your Cloudflare account.

`threat_control` Resource
-------------------------------
CloudFlare's threat control can be used to whitelist or blacklist IPs hitting your domains going through their network.
cf. [CloudFlare FAQ - How do I block or trust visitors in Threat Control?](https://support.cloudflare.com/hc/en-us/articles/200171266-How-do-I-block-or-trust-visitors-in-Threat-Control-)

Attribute:

* `ip` (optional): the IP of the server you want to manipulate. Defaults to the current node IP.

Actions: `:whitelist`, `:blacklist`, `:remove_ip`
Should be self-explanatory, the latter one being used to remove a white/blacklisted IP from their respective list.

Examples:

    cloudflare_threat_control 'whitelist_current_server' do
      action :whitelist
    end

    cloudflare_threat_control 'shall_we_trust_this?' do
      ip '208.73.210.203'
      action :blacklist
    end


Example recipe
==============

You can have a look at the `cloudflare::example` recipe for examples on how to use the LWRPs.

You can also test my cookbook with Vagrant (see the 'Vagrant' section below).

Vagrant
=======

You can test this cookbook locally, provided you have a bunch of free software installed, namely [Vagrant](https://www.vagrantup.com/downloads), [Berkshelf](http://berkshelf.com/), [VirtualBox](https://www.virtualbox.org/), and a couple of Vagrant plugins: [Vagrant-Berkshelf](https://github.com/berkshelf/vagrant-berkshelf) and [Vagrant-Omnibus](https://github.com/schisamo/vagrant-omnibus).

You also need to define 3 environment variables to be able to use my Vagrantfile:

* `CLOUDFLARE_EMAIL`
* `CLOUDFLARE_API_KEY`
* `CLOUDFLARE_DOMAIN`

You can do so by typing e.g. `export CLOUDFLARE_EMAIL='me@example.com'` and so on in your shell.

Be aware that the example recipe will then proceed to create a few DNS records on that DNS zone with your credentials, so use with caution! That being said, all said records will start with 'cl-cb-test-' so they have little chance of clonflicting with exisiting records on your account.

You can also easily clean up the test records created that way by running `CLOUDFLARE_CLEANUP=1 vagrant provision`.

Then playing with this cookbook should be as easy as running `bundle install --path vendor/bundle && vagrant up`!

Contributing & Feedback
=======================

As always, I appreciate bug reports, suggestions, pull requests, feedback...
Feel free to reach me at <wk8.github@gmail.com>

Changes
=======

* 0.1.7
    * Added the `threat_control` LWRP allowing to whitelist or blacklist IPs on CloudFlare

* 0.1.6 (Jul 9, 2014)
    * Added the `shared_A_record` attribute to the LWRP to make it possible to have several A records with the same name (aka DNS load balancing)
    * Properly updating LWRP states when an action has been performed
    * More complete example recipes (should integrate Test Kitchen soon)

* 0.1.5 (Jul 8, 2014)
    * Included Vagrant & Berkshelf for easier development

* 0.1.4 (Apr 23, 2014)
    * Fixed a bug when there were too many records to be loaded in one call from CloudFlare
    * Made it more compliant with ill-formatted record names

* 0.1.3 (Mar 21, 2014)
    * Upgraded the Cloudflare gem to the newest version 2.0.1

* 0.1.2 (Nov 14, 2013)
    * Changed default DNS server from Google's to Cloudflare's to avoid new records from not resolving for a long time on Google's server

* 0.1.1 (Nov 6, 2013)
    * Some small bug fixes
    * Reduced the number of calls to the Cloudflare API with the vanilla options
    * Added a number of options to reduce the number of calls to the Cloudflare API further, most notably made it possible to query a DNS server to check records' existence

* 0.1.0 (Oct 3, 2013)
    * Initial release
