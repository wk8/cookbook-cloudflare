# CHANGELOG for cloudflare

This file is used to list changes made in each version of cloudflare.

## 0.1.2:

* Changed default DNS server from Google's to Cloudflare's to avoid new records from not resolving for a long time on Google's server

## 0.1.1:

* Some small bug fixes
* Reduced the number of calls to the Cloudflare API with the vanilla options
* Added a number of options to reduce the number of calls to the Cloudflare API further, most notably made it possible to query a DNS server to check records' existence

## 0.1.0:

* Initial Release of cloudflare
