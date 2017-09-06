---
title: "Using napalm-logs for event-driven network automation and orchestration"
author: mirceaulinic
description: "Using napalm-logs for event-driven network automation and orchestration"
tags: ["post", "napalm-logs", "yang"]
---

After months of continuous work, we are thrilled to announce the first major
release of [*napalm-logs*](https://github.com/napalm-automation/napalm-logs).

# What is napalm-logs

*napalm-logs* is open source software acting as a daemon, which listens for
syslog messages from network devices and normalizes them into a vendor-agnostic
shape. Unlike the rest of the libraries maintained by the NAPALM automation
community, *napalm-logs* does not connect to the device to retrieve information,
but rather receives messages.

<!--more-->

The messages are received either directly from the network device, via UDP or TCP,
or indirectly, using brokers such as [Kafka](https://kafka.apache.org/),
[ZeroMQ](http://zeromq.org/), or other external systems. This is called
the *listener* interface and it is pluggable, meaning that the user can easily
extend its capabilities and facilitate the reception of the syslog messages from
various different sources.

syslog messages are simple chunks of text which don't confirm to the same format
or structure across network operating systems. syslogs do however have something
in common, they are notifications of events occurring on the device. This is the
way the network device communicates back about what is going on.

For example, the following syslog message is a notification received from a
Juniper device. The event occurring is a bgp neighbor receiving more prefixes
than is configured to be allowed, once the threshold is breached the neighbor
has been torn down:

```text
<149>Jun 21 14:03:12  vmx01 rpd[2902]: BGP_PREFIX_THRESH_EXCEEDED: 192.168.140.254 (External AS 4230): Configured maximum prefix-limit threshold(140) exceeded for inet4-unicast nlri: 141 (instance master)
```

A similar notification, from a Cisco IOS-XR device, has a totally different form,
but the device is communicating exactly the same notification:

```text
<149>2647599: xrv01 RP/0/RSP1/CPU0:Mar 28 15:08:30.941 UTC: bgp[1051]: %ROUTING-BGP-5-MAXPFX : No. of IPv4 Unicast prefixes received from 192.168.140.254 has reached 94106, max 12500
```

The same notification from a Cisco NXOS, or Arista EOS device, and so on, has a
different structure, although the device is sending the same
information.

*napalm-logs* is important from this perspective, as it provides the abstraction
layer, in such a way that the raw syslog messages above are translated into
structured data, e.g.:

```json
{
  "error": "BGP_PREFIX_THRESH_EXCEEDED",
  "facility": 18,
  "host": "vmx01",
  "ip": "127.0.0.1",
  "os": "junos",
  "severity": 5,
  "timestamp": 1498053792,
  "yang_message": {
      "bgp": {
          "neighbors": {
              "neighbor": {
                  "192.168.140.254": {
                      "afi_safis": {
                          "afi_safi": {
                              "inet4": {
                                  "ipv4_unicast": {
                                      "prefix_limit": {
                                          "state": {
                                              "max_prefixes": 140
                                          }
                                      }
                                  },
                                  "state": {
                                      "prefixes": {
                                          "received": 141
                                      }
                                  }
                              }
                          }
                      },
                      "state": {
                          "peer_as": "4230"
                      }
                  }
              }
          }
      }
  },
  "yang_model": "openconfig-bgp"
}
```

Now, let's analyse each field from the snippet above:

``yang_model``: simply names the YANG model that is used to standardize the
outgoing document. In the previous example, its value is ``openconfig-bgp``
which means that the hierarchy respects the defined hierarchy from the
[openconfig-bgp](http://ops.openconfig.net/branches/master/docs/openconfig-bgp.html)
YANG model.

``error``: is a cross-platform unique identifier of the notification.
To see the complete list of available notification identifiers, please check
the [official documentation](http://napalm-logs.readthedocs.io/en/latest/messages/index.html).

``facility`` & ``severity``: looking at the above raw messages, they start
with ``<149>``. That is *the PRI part* (see
[RFC 3164, &para;4.1.1](https://www.ietf.org/rfc/rfc3164.txt)). The PRI is a
code that represents the *facility* and the *severify*. The severity can have
a value between 0 (i.e., *emergency: system is unusable*) and 7 (i.e.,
*debug-level messages*). The facility, on the other hand is usually standardised
as well, but there are also some vendor/platform specifics. For more information
read [this document](https://www.balabit.com/documents/syslog-ng-ose-latest-guides/en/syslog-ng-ose-guide-admin/html/bsdsyslog-pri.html).
In our examples, severity level 5 means *Notice: normal but significant condition*,
while facility number 18 corresponds to BGP.

``host``: is extracted from the syslog message, it represents the hostname of the
network device.

``ip``: the IP address the device the message was recevied from.

``os``: is the name of the network operating system identified from the syslog
message format.

``timestamp`` is the UTC timestamp of wen the syslog message was generated, not
when received from the device.

## Where are these messages available

These structured messages are then published over various systems such as ZeroMQ
(used by default), Kafka, et al. Similarly to the *listener* interface, the
*publisher* interface is equally pluggable and the community can always contribute
to extend the list of available transport.

The outgoing messages are binary serialized using [MessagePack](http://msgpack.org/)
and can be consumed using multiple clients.

Considering that the napalm-logs messages can be used for event-driven automation
and eventually trigger completely automatic configuration changes, we must ensure
the authenticity of the messages. For this reason napalm-logs has been designed
with security in mind, the serialized data is encrypted and signed before
being published. With that said, the user must also ensure the client connecting
to napalm-logs' publisher interface is designed with the ability to decrypt and
check the signature of the received messages. For more details on  how to easily
implement the security on the client side, have a look at the
[Client Authentication](http://napalm-logs.readthedocs.io/en/latest/authentication/index.html).

## Installation

The library is available on [PyPI](https://pypi.python.org/pypi) (Python Package
Index), which is the official repository for third-party Python libraries:

```bash
$ pip install napalm-logs
```

Which will also install the napalm-logs binary. For more specific installation
notes, see [this document](http://napalm-logs.readthedocs.io/en/latest/installation/index.html).

## How to start napalm-logs

In the [main documentation](http://napalm-logs.readthedocs.io/en/latest/index.html)
we explain briefly the ways to get started. You first need to determine if you
*really* want to disable security.

The easiest example to start with is the following:

```bash
$ sudo napalm-logs --publisher cli --disable-security
```

The above is highly discouraged in production environments, as it disables
the security and just prints the objects on the command line; this is however a
good way to check that the process is running correctly and receiving syslog
messages. By default it is listening on the standard syslog UDP port ``514``
(hence the need to start it with ``sudo``). To use a different port, you can use
the [``port`` configuration option](http://napalm-logs.readthedocs.io/en/latest/options/index.html#port).

The list of configuration options can grow significantly, although they can be
equally specified on the command line when starting the daemon, it is preferable
to add them into a configuration file (default: ``/etc/napalm/logs``):

``/etc/napalm/logs``

```yaml
address: 172.17.17.1
port: 5514
disable_security: true
publish_address: 172.17.17.2
publish_port: 49017
transport: zmq
```

Start the program with: ```$ napalm-logs -c /etc/napalm/logs```. The config
above will be listening to syslog messages over UDP at ``172.17.17.1:5514``, and
will be publishing the structured messages, without encryption, over ZeroMQ
at ``172.17.17.2:49017``.

## When to use napalm-logs

It has been implemented to be suitable for various topologies, including, for
example:

- *napalm-logs* listening close to the network devices, e.g., one instance per PoP, or datacenter.
- Playing the role of a central collector (if you are entirely sure that nobody will spoof, replay etc, the UDP messages between the network devices and napalm-logs).
- A load-balanced central collector, meaning that you can start many processes.
- The network devices sending the raw syslog messages to brokers such as Apache Kafka and *napalm-logs* processing them by subscribing to a dedicated topic.

There are no design constraints and you can run as many instances as you want.

## How to consume the napalm-logs messages

There are almost an unlimited number of ways to connect to the publisher
interface, it mostly depends on the application and the topology you choose to
implement. The most straight forward way is having one *napalm-logs* instance
and one (or more) clients subscribing to the ZeroMQ bus -- we have added an
example like that [here](http://napalm-logs.readthedocs.io/en/latest/authentication/index.html),
the source code being also available
[on GitHub](https://github.com/napalm-automation/napalm-logs/blob/master/examples/client_auth.py).

## The napalm-syslog Salt engine

The capabilities of napalm-logs are directly exploited in Salt, beginning with
the *Nitrogen* release - see
[the release notes](https://docs.saltstack.com/en/latest/topics/releases/2017.7.0.html#network-automation).
By configuring the [*napalm-syslog*](https://docs.saltstack.com/en/latest/ref/engines/all/salt.engines.napalm_syslog.html#module-salt.engines.napalm_syslog)
Salt engine, we can import the structured messages directly into the Salt event bus.

The configuration is simple: once you have the *napalm-logs* daemon running,
the *napalm-syslog* Salt engine requires the configuration of the options
documented [here](https://docs.saltstack.com/en/latest/ref/engines/all/salt.engines.napalm_syslog.html#salt.engines.napalm_syslog.start).

For example:

```yaml
engines:
  - napalm_syslog:
      transport: zmq
      address: 172.17.17.2
      port: 49017
```

One detail to note is that the ``address`` and ``port`` options on the Salt
engine side correspond to the ``publish_address`` and ``publish_port`` from
*napalm-logs*.

Once everything is working, we should see events with the following structure
on the Salt event bus:

```json
napalm/syslog/junos/BGP_PREFIX_THRESH_EXCEEDED/vmx01 {
  "error": "BGP_PREFIX_THRESH_EXCEEDED",
  "facility": 18,
  "host": "vmx01",
  "ip": "127.0.0.1",
  "os": "junos",
  "severity": 5,
  "timestamp": 1498053792,
  "yang_message": {
      "bgp": {
          "neighbors": {
              "neighbor": {
                  "192.168.140.254": {
                      "afi_safis": {
                          "afi_safi": {
                              "inet4": {
                                  "ipv4_unicast": {
                                      "prefix_limit": {
                                          "state": {
                                              "max_prefixes": 140
                                          }
                                      }
                                  },
                                  "state": {
                                      "prefixes": {
                                          "received": 141
                                      }
                                  }
                              }
                          }
                      },
                      "state": {
                          "peer_as": "4230"
                      }
                  }
              }
          }
      }
  },
  "yang_model": "openconfig-bgp"
}
```

The event tag ``napalm/syslog/junos/BGP_PREFIX_THRESH_EXCEEDED/vmx01`` can then
be used to identify events and trigger jobs, e.g., fully automatic configuration
changes, or simple notifications in a Slack channel etc. This would be a very
elegant way to automate your infrastructure and understand better your network.

## Streaming Telemetry vs. napalm-logs

This software does not aim to provide an alternative to the steaming telemetry:
while napalm-logs normalises simple and very specific notifications, telemetry
sends state information. They can both co-exist and provide important information.

## Conclusion

Any network can produce millions of syslog messages per hour. We believe
that it's vital to consider this information and act according to business
requirements. At times, the syslog messages can be critical for your infrastructure:
applying automatic configuration changes when, for example, a BGP neighbor is
leaking their entire routing table might be the key to maintain your network
stability; *napalm-logs* is an important ally in multi-platform environments.

This is just the very beginning of event-driven network automation and
orchestration. As with any open source software we welcome your ideas, bug
reports, bug fixes, improvements, feature additions or modules for one of the
pluggable interfaces - we already have a
[bunch of ideas](https://github.com/napalm-automation/napalm-logs/issues)
for the future releases. Documentation improvements are equally important and
we will be happy to merge your pull requests!
