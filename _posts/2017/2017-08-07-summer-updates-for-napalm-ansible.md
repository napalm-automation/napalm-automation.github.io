---
title: "Summer updates for napalm-ansible"
description: "Install napalm modules for ansible the easy way"
tags: ["news", "ansible"]
---

Ansible doesn't have one of the best user experiences out there when it comes to installing third party modules. The process usually involves cloning a repo and updating `ansible.cfg` to make sure the cloned repo is in the path. This is not particularly terrible but it becomes an issue when you come to the realization you have to make sure yourself that the repo stays up to date, which means you have to keep track of every potential repo yourself and that you have to understand how each potential project that provides third party modules prefers to deal with versioning for ansible modules.

<!--more-->

To simplify how to deal with this, at least for modules provided via `napalm-ansible`, we are providing now the modules via `pip`. This means you can install/upgrade/version your modules as you would with ansible itself. For example, the requirements file for your ansible project could easily look like:

	# requirements.txt
	ansible<2.5
	napalm-ansible<0.8

You still have to configure ansible to find the modules, not much we can do there, so in order to guide you on how to do that `napalm-ansible` provides a CLI tool with the same name that will guide you in the process. For example:

	$ napalm-ansible
	To make sure ansible can make use of the napalm modules you will have
	to add the following configurtion to your ansible configureation
	file, i.e. `./ansible.cfg`:

			[defaults]
			library = /Users/dbarroso/.virtualenvs/ansible_project/lib/python2.7/site-packages/napalm_ansible

	For more details on ansible's configuration file visit:
	https://docs.ansible.com/ansible/latest/intro_configuration.html

As simple as that. And, of course, if you want to upgrade `napalm-ansible` to the latest version you can just do `pip install -U napalm-ansible` or if you want to revert to a previous version you can `pip install napalm-ansible==0.6.1`.

Happy automation!
