---
title: "Nuts - Network Unit Test System Edit"
author: ubaumann
description: "Create the capability to test you own network with unit tests"
tags: ["post", "nuts", "testing"]
---

Network vendors manage in different ways to make the life of a network automation engineer harder.
Yet, some vendors are worse than others. For instance, two different platforms of the same vendor
can have different implementations of the same capability. Even an upgrade can break your automation tools.
In a multi-vendor environment, we will always be faced with differences. Every vendor tries to get a
unique selling proposition.

# Testing is important

NAPALM and its community do a great job in abstracting the complexity of the different implementations.
However, you will have to test your code accurately and you need to test it on your real platform versions.

<!--more-->

But how can you be sure your automation works like a charm? There are so many dependencies.
Sessions can time out, network devices are sometimes too busy or the vendor may have some bad implementations.
After a change, the network must be verified or even better tested. To avoid side effects, verifying, however,
is in most cases not enough. The network is a complex ecosystem and a small change can affect other features.

Nuts is a network unit testing solution which runs tests in your entire network. In software engineering,
its testing is state of the art. In software projects, the programmer implements tests to make sure the piece
of code is working properly. In terms of future changes, the created tests are executed to avoid side effects
and so as not to break any features. Nuts creates the same capability for the network, creates tests and checks
if all the tests are still working after a change.

Example for a bandwidth test:

```yaml
- name: bandwidth_ping
  command: bandwidth
  devices: srvlnx0001
  parameter: ['{% raw %}{{ ip[0] }}{% endraw %}']
  operator: '<'
  expected: 100000000
  setup:
  - command: network.ip_addrs
    devices: srvlnx0099
    save: ip
  - command: cmd.run
    devices: srvlnx0099
    parameter: ['iperf3 -s -D -1']
  teardown:
  - command: cmd.run
    parameter: ['pkill iperf3']
    devices: srvlnx0099
```

# Idea was born

Everything started in a late-night core change with the detection of some weird behavior two years ago.
After rollbacking, changing and configuring VRF and interfaces again, the hard part began:
Testing the entire network. Some hours after midnight, we reached the point when we said, all services should
be running as expected and only the engineering office would be affected. 2 days later we realized, the VoIP
phones couldn't renew the DHCP release. I don't know how, but we lost one SVI of the `ip address helper`.
Our findings of this change were: a better testing strategy is needed. The optimal way to solve the current
problem was an automated unit testing for the network environment.

![simple testing topology]({{ site.url }}/images/2017/nuts-network-unit-testing-overview.png)

# Bachelor Thesis

Two students created the first version of Nuts after completing their Bachelor Thesis called
"Unit testing in the network". A lot of time was spent on parsing the CLI commands. This part has now been
solved with Salt and the NAPALM modules. Also, the SaltStack integration has now been realized through the
Salt API.

Nuts supports different test commands for network devices and / or Linux devices. For more details,
please check the [*documentation:*](http://nuts.readthedocs.io/en/develop/tests/index.html). More and more test
will be implemented in the future. Your feedback and contribution is always welcome.

```sh
$ nuts mytest.yml -c myconfig.yml

TestCases:
Async Tests:
Name: version_chk_01, Command: checkversion, Devices: csr_01, Parameter: [], Operator: =, Expected: CSR1000V Software (X86_64_LINUX_IOSD-UNIVERSALK9-M), Version 15.5(2)S, RELEASE SOFTWARE (fc3)
Sync Tests:
Name: bandwidth_ping, Command: bandwidth, Devices: srvlnx0001, Parameter: ['{{ ip[0] }}'], Operator: <, Expected: 100000000
Start test version_chk_01
Started test 1 of 1
----------------Started all async tests-------------
CollectResult of Test version_chk_01
Collected results from 1 of 1 tests
--------------Collected all async results-----------
Start Test bandwith_ping


version_chk_01: Test passed -------------------------

bandwidth_ping: Test passed -------------------------

---------------------Summary----------------------
2 out of 2 tests passed
```
