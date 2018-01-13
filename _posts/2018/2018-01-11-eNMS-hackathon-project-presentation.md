---
title: "eNMS: a vendor-agnostic Network Management System using NAPALM for network automation"
author: afourmy
description: "Introduction to eNMS"
tags: ["news"]
---

During the Hackathon, I worked on eNAPALM, a simple web interface to Netmiko and NAPALM. 
The idea was to provide a way to use netmiko and napalm for those who don't have any Python or Ansible knowledge.

After a few weeks, I decided to start all over from scratch and created a whole new project designed to be a Network Management System focused on network visualization and automation: **eNMS**.

**You can find a demo of eNMS _[here](http://afourmy.pythonanywhere.com/)_ !**
```
Username: cisco
Password: cisco
```

In this post, I will start by briefly introducing eNMS network automation features, then show with some practical video examples of Netmiko and NAPALM automation on a Cisco 1841 (IOS) with eNMS.

# eNMS network automation features

## Types of task

There are four types of task in eNMS:
- **Netmiko _configuration_ task**: list of commands to configure the device (plain text or Jinja2 template).
- **Netmiko _show commands_ task**: list of “show commands” which output is displayed in the task logs.
- **NAPALM _configuration_ task**: partial or full configuration (plain text or Jinja2 template).
- **NAPALM _getters_**: list of getters which output is displayed in the task logs.

For all tasks, the user can choose one or more target devices.

## Task scheduling

eNMS also provides some scheduling functions:
- **Start date**: instead of running the task immediately, the task starts at a specific time.
- **Frequency**: the task is run periodically. This is especially useful for tasks that pull some information from the device, i.e netmiko **_show commands_** / **_NAPALM getters_** tasks.

# How to use eNMS: a few examples

## First step: import your network

Nodes and links can be created in two ways: 
- one by one by specifying all properties manually, in the _Object creation_ page.
- by importing an Excel file with one sheet per type of object.
Examples of such Excel files are available in the **_/project folder_**.

Once your objects have been created, you can go to the _Overview_ page. All objects are displayed in a sortable and searchable table.

![Object creation](https://raw.githubusercontent.com/napalm-automation/napalm-automation.github.io/master/images/2018/eNMS-hackathon-project-presentation-object_creation.gif)

## Simple configuration script with Netmiko

- Create a script in the _Script creation_ page.
- Set the script parameters (netmiko driver, global delay factor, target devices).

![Simple script with netmiko](https://raw.githubusercontent.com/napalm-automation/napalm-automation.github.io/master/images/2018/eNMS-hackathon-project-presentation-netmiko_simple.gif)

## Template-based configuration

For complex script, it is best to use Jinja2 templating language:
- Write a Jinja2 template in the _Script creation_ page.
- Import a YAML file that contains all associated variables.

eNMS will take care of converting the template to a real text-based script.

![Send jinja2 script via SSH with netmiko](https://raw.githubusercontent.com/napalm-automation/napalm-automation.github.io/master/images/2018/eNMS-hackathon-project-presentation-netmiko_j2.gif)

## NAPALM configuration

NAPALM can be used to change the configuration (merge or replace), either via a plain text script or a Jinja2-enabled template.

![Use NAPALM to configure static routes](https://raw.githubusercontent.com/napalm-automation/napalm-automation.github.io/master/images/2018/eNMS-hackathon-project-presentation-napalm_config.gif)

## Netmiko _show commands_ periodic retrieval

You can schedule a task to retrieve the output of a list of commands (show, ping, traceroute, etc) periodically. The result is stored in the database and displayed in the logs of the task, in the _Task management_ page.

![Netmiko show](https://raw.githubusercontent.com/napalm-automation/napalm-automation.github.io/master/images/2018/eNMS-hackathon-project-presentation-netmiko_show.gif)

## NAPALM _getters_ periodic retrieval

You can also schedule a task to retrieve a NAPALM getter periodically.

![Configuration automation with NAPALM and Jinja2 scripting](https://raw.githubusercontent.com/napalm-automation/napalm-automation.github.io/master/images/2018/eNMS-hackathon-project-presentation-napalm_getters.gif)

## Comparison

For all periodic tasks, you can compare the results between any two devices, at two different times.

The comparison result is displayed with two methods:
- A **_unified diff_**: show just the lines that have changed plus a few lines of context, in an inline style. (like Git)
- A **_ndiff_**: list every line and highlights interline changes.

![Comparison](https://raw.githubusercontent.com/napalm-automation/napalm-automation.github.io/master/images/2018/eNMS-hackathon-project-presentation-comparison.gif)

# eNMS technical stack

## Back-end

- Web framework: Flask
- Database: SQLAlchemy / SQLite (possible migration to PostgreSQL soon)
- Task scheduling: AP Scheduler (via flask_apscheduler)

## Front-end

A Bootstrap template called _[Gentelella](https://github.com/puikinsh/gentelella)_, and a number of JavaScript libraries.

# More

You can find more information about eNMS on _[Github](https://github.com/afourmy/eNMS)_