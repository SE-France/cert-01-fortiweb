# FortiWEB® hook for `dehydrated`

This is a hook for the [Let's Encrypt](https://letsencrypt.org/) ACME client [dehydrated](https://github.com/lukas2511/dehydrated) (previously known as `letsencrypt.sh`) that allows you to use [Fortinet® FortiWeb®](https://www.fortinet.com/products/web-application-firewall/fortiweb.html) to host your certificates.

Tested on FortiWEB® 5.8.2

## Requirements

```
$ sudo apt-get update
$ sudo apt-get -y openssl curl sed grep mktemp git jq
```

## Installation

```
$ cd ~
$ git clone https://github.com/lukas2511/dehydrated
$ cd dehydrated
$ mkdir hooks
$ git clone https://github.com/SE-France/cert-01-fortiweb hooks/cert-01-fortiweb
```

## Configuration

This hook uses Fortinet FortiWEB® API. This project host your certificates for the domain (or a subdomain) you want to get a Let's Encrypt certificate for. Also, if you use the FortiADC® as a GSLB, you may look at this [FortiADC hook](https://github.com/SE-France/dns-01-fortiadc). 

You need to create and edit a config file based on `fortiweb.conf.default`

```
$ cd hooks/cert-01-fortiweb
$ cp -a fortiweb.conf.default fortiweb.conf
```

Also you need to change the following settings in your dehydrated config (original value commented out):
```
# Which challenge should be used? Currently http-01 and dns-01 are supported
#CHALLENGETYPE="http-01"
CHALLENGETYPE="dns-01"
``` 

If you use FortiWEB® as a HTTPS load balancers®, you need to align your setup of target proxies with how you create the certificates. All domains served by a target proxy have to be in the same certificate. If that is more than one, you cannot use the -d command line option of dehydrated. Instead you have to create a domains.txt file. The following example assumes you have two target proxies; one serving requests for example.com and www.example.com. And the second one serving wwwtest.example.com:

domains.txt
``` 
example.com www.example.com
wwwtest.example.com
``` 


## Usage

```
$ ./dehydrated -c -t dns-01 -k 'hooks/cert-01-fortiweb/hook.sh'
```

The ```-t dns-01``` part can be skipped, if you have set this challenge type in your config already. Same goes for the ```-k 'hooks/cert-01-fortiweb/hook.sh'``` part, when set in the config as well.

## More info

More hooks: https://github.com/lukas2511/dehydrated/wiki/Examples-for-DNS-01-hooks

Dehydrated: https://github.com/lukas2511/dehydrated


Copyright © 2017 Fortinet, Inc. All rights reserved. Fortinet®, FortiADC®, FortiWEB® and certain other marks are registered trademarks of Fortinet, Inc., and other Fortinet names herein may also be registered and/or common law trademarks of Fortinet. 
