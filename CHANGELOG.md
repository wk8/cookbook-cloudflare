# CHANGELOG for cloudflare

This file is used to list changes made in each version of cloudflare.

## 0.1.7:

* Added the `threat_control` LWRP allowing to whitelist or blacklist IPs on CloudFlare

## 0.1.6:

* Added the `shared_A_record` attribute to the LWRP to make it possible to have several A records with the same name (aka DNS load balancing)
* Properly updating LWRP states when an action has been performed
* More complete example recipes (should integrate Test Kitchen soon)

## 0.1.5:

* Included Vagrant & Berkshelf for easier development

## 0.1.4:

* Fixed a bug when there were too many records to be loaded in one call from CloudFlare
* Made it more compliant with ill-formatted record names

## 0.1.3:

* Upgraded the Cloudflare gem to the newest version 2.0.1

## 0.1.2:

* Changed default DNS server from Google's to Cloudflare's to avoid new records from not resolving for a long time on Google's server

## 0.1.1:

* Some small bug fixes
* Reduced the number of calls to the Cloudflare API with the vanilla options
* Added a number of options to reduce the number of calls to the Cloudflare API further, most notably made it possible to query a DNS server to check records' existence

## 0.1.0:

* Initial Release of cloudflare
