cloudstack CHANGELOG
====================

This file is used to list changes made in each version of the co-cloudstack cookbook.

3.0.3
-----
- pdion891 - api_key: add existing keys validation to fix admin password change.

3.0.2
-----
- pdion891 - Add eventlog to rabbitmq config template

3.0.0
-----
- pdion891 - Complete rewrite of co-cloudstack as cloudstack using Chef LWRP
- pdion891 - Rename cookbook from co-cloudstack to cloudstack.

2.0.3
-----
- pdion891 - Add mysql-conf to configure mysql-server tunings required by CloudStack.

2.0.2
-----
- pdion891 - change way of generating APIkeys by querying CloudStack API instead of enabling integration api port.

2.0.0
-----
- pdion891 - add support for CS 4.3

1.0.0
-----
- pdion891 - add vhd-util recipe
- Update license headers
- Update dependencies for opscode cookbooks

0.1.2
-----
- pdion891 - remove use of databag and use attributes instead.

0.1.0
-----
- pdion891 - Initial release of co-cloudstack

