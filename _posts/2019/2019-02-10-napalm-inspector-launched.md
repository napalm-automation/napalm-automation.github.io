---
title: "Napalm-inspector 1.0.0 Released"
author: ogenstad
description: "Napalm-inspector is a web application aimed to help troubleshoot the Napalm getters"
tags: ["news"]
---
I wish I could say that you should be excited about Napalm-inspector. Unfortunately, very little unicorn SDN is involved in this new tool, it's actually a pretty dull application. It's not the type of tool that will propel you to the next level in your network automation journey and allow you to crush it. Instead, Napalm-inspector is a web application aimed to help with the work on bug fixes and troubleshooting around the Napalm getters. 
<!--more-->

### What is a Napalm getter?
One of the goals of Napalm is to provide its users with a unified API which can return structured data which follows the same format regardless of device type. For example, if you use the [get_bgp_neighbor()](https://napalm.readthedocs.io/en/latest/base.html#napalm.base.base.NetworkDriver.get_bgp_neighbors) function the data will look the same regardless if you target a Cisco IOS device, a Cisco IOS XR one or a Junos router. For some of the platforms that Napalm supports the data is already in a structured format, and all Napalm has to do is to transform the data in the format that Napalm uses.

### Problems with getters and how they can break
However, for some devices, the data is entirely unstructured, so Napalm needs to parse the output from these platforms to make sense of the data. For devices in this category, Napalm sends show commands to them and feeds the output through the parsing engine. For each getter, Napalm runs one or more commands and analyzes the output. In a perfect world, this would be done once for each getter function, and everything would work. In our world this is where the unicorn starts to cry. Sadly the output for a given command often differs between versions of the same NOS and, in some cases, even different commands are needed to gather the needed information.

### Reporting bugs and troubleshooting
Typically what happens is that someone runs into a bug with one of the getters. It could be that the output gets parsed incorrectly or that an exception gets raised. At this stage, someone would [report an issue](https://github.com/napalm-automation/napalm/issues). In some cases, it isn't apparent what happens under the hood and time needs to get spent for the development team to collect the required information needed to troubleshoot the issue.

### How napalm-inspector can help
Napalm-inspector is a [Flask](https://palletsprojects.com/p/flask/) application that simulates what the getters would do. Instead of connecting to devices a user would choose a getter to test, and napalm-inspector will ask the user to provide the output from one or more commands.

For example, to collect the data from get_facts on IOS, Napalm would execute:
```
show version
show hosts
show ip interface brief
```
The idea is that you can run Napalm-inspector to test one of the getters, once it has the output from all of the commands the application will present everything that should be needed when filing a [Napalm bug report](https://github.com/napalm-automation/napalm/issues).

### Running napalm-inspector
To test Napalm-inspector, you can install it like any other Python tool:

```
pip install napalm-inspector
```

Start the application by setting the FLASK_APP environment variable and starting flask.

```bash
export FLASK_APP=napalm_inspector
flask run
 * Serving Flask app "napalm_inspector"
 * Environment: production
   WARNING: Do not use the development server in a production environment.
   Use a production WSGI server instead.
 * Debug mode: off
 * Running on http://127.0.0.1:5000/ (Press CTRL+C to quit)
```
At this stage, you can access napalm-inspector by visiting http://127.0.0.1.

![Napalm Inspector](/images/2019/napalm-inspector-homescreen.png)

Click to test one of the getters and choose the platform. In this version, Cisco IOS and the Cisco NXOS SSH drivers are supported. Under each platform you will have a number of getters to chose from.

Testing get_arp() against an IOS device will ask you to provide the output from "show arp | exclude Incomplete"
![Napalm Inspector get_arp()](/images/2019/napalm-inspector-get-arp.png)
Press Submit until napalm-inspector stops asking for output or until an error is raised. If the output is incorrect or Napalm runs into an exception please open an issue and copy the information at the bottom of the page.

### Project information
The source code is available at Github in the [napalm-inspector repo](https://github.com/napalm-automation/napalm-inspector).