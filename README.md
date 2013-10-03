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
* `ttl` (must be a `Fixnum` - defaults to `1`, which, according to Cloudflare doc, means 'automatic'): the ttl of the DNS record

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


Changes
=======

* 0.1.0 (Oct 3, 2013)
    * Initial release
