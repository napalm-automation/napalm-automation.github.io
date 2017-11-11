---
title: "Nuts - Network Unit Test System Edit"
author: ubaumann
description: "Create the capability to test you own network with unit tests"
tags: ["post", "nuts", "testing"]
---

> This is a guest post by **ubaumann** about how he leverages napalm. If you want to share with the community your tool or use case leveraging napalm don't hesitate to contact us.
> The views of guest authors are their own and doesn't necessarily correspond with the view of the napalm-automation group.

Network vendors manage to make the life of network automation engineers difficult in different ways.
Yet, some vendors are worse than others. For instance, two different platforms of the same vendor
can have different implementations for the same capability. Even different versions can behave differently so
a simple upgrade can break your automation tools.
In a multi-vendor environment, we will always be faced with differences as every vendor tries to get a
unique selling proposition.

# Testing Is Important

NAPALM and its community do a great job in abstracting the complexity of the different implementations.
However, you will have to test your code accurately and that sometimes means testing with real hardware.

<!--more-->

But how can you be sure your automation works like a charm? There are so many things that can fail.
Sessions can time out, network devices are sometimes too busy to perform an action or a particular implementation may have bugs.
After a change, the network configuration change must be verified for correctness. Ideally, in addition, the network would be tested after the change. To detect side effects verifying changes is not enough as
 networks are complex systems and a small change can affect other features in the same device or even cause an unexpected change somewhere else in the network.

In software projects, programmers implement unit tests to make sure different pieces of code work as intended. These tests also serve in future releases to ensure already fixed bugs don't reappear, this is often referred as regression tests. Nuts is a network unit testing solution which can run tests anywhere in your network and allows to apply the same testing principles. For example, when doing QoS changes you could add a unit test to verify bandwidth:

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

# An Idea Was Born

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
"Unit testing in the network". At that time, a lot of time was spent developing a mechanism to execute and parse CLI commands on various devices and integrating with SaltStack. Thanks to NAPALM and its salt integration Nuts con now focus on the testing framework itself and leverage on NAPALM/SalstStack to retrieve the necessary information from the network.

Nuts supports different test commands for network devices and / or Linux devices. For more details,
please check the [*documentation:*](http://nuts.readthedocs.io/en/develop/tests/index.html). More and more test
will be implemented in the future. Your feedback and contribution is always welcome.
