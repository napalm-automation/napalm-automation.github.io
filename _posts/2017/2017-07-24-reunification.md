---
title: "Reunification"
description: "Drivers will be merged soon. Do you want to know more?"
tags: ["news"]
---

We are evaluating the possibility to merge all the drivers back together. This may or may not have any impact on you but we wanted to share the background of this story, the reasoning for doing that, the technical challenges and solutions for doing so, the potential implications for users and the proposed timeline for it.

The proposed date for the reunification is **October 20th 2017**.

<!--more-->

Background
==========

As some of you may remember, back in the day NAPALM was a single repository where all the drivers coexisted together. As drivers and contributors exploded in number we started facing two issues:

1. Dependencies grew dramatically as many drivers had different dependencies and that was an issue for people that wanted to install the drivers in systems with more limited resources.
2. PRs were hard to manage and review as contributors often would send unrelated features for unrelated vendors all bunched together in the same PR. Different maintainers have different expertise so while I could easily review a PR with code for `eos` I might be completely unprepared to review code for `nxos`.

To try to overcome those issues we proposed splitting the drivers into different repos. That way drivers could easily be installed individually and contributors would be forced to send different PRs for different vendors. Obviously this sparked some debate with some people advocating this would just move the problem around rather than fixing it. There were many good arguments both in favor and against the move and we finally decided to move forward with the split.

Well, it turns out they were right, having an individual repo for each driver removed an administration problem but added an unforeseen one; in the past year we have been trying to improve the API with minor tweaks to existing methods; i.e. adding a `commit_confirm`-like option to the `commit_config` method. This has proven to be a nightmare with the current structure as changes have to be synchronized amongst many repos. Another issue is that keeping track of issues and PRs requires navigating a myriad of different URLs and it becomes tedious and cumbersome for the core maintainers.

Proposed Solution
=================

To err is human and we are not afraid of recognizing we took the wrong decision so we are evaluating how to solve the current problem we are facing while not breaking anything or introducing the old problems back.

Please, take the next idea as just that, an idea, we will provide a github issue so people can voice their opinions/concerns and we will also publish further blog posts along the road as the plan starts to form.

The rough plan we have so far is as follows:

1. Reunify drivers back under the `napalm` repo bumping the version to `2.0.0`.
2. Manage dependencies via [extras_require](https://setuptools.readthedocs.io/en/latest/setuptools.html#declaring-extras-optional-features-with-their-own-dependencies). This would allow you to do things like `pip install napalm[ios,eos]` and install only the dependencies for `ios` and `eos` or just do `pip install napalm` to install everything.
3. Make sure contributors understand unrelated features shouldn't be included in the same PR unless there is a good reason for that.

Obviously point 3 is a human problem with a non-technical solution but we feel the community and the project are mature enough that people will understand that contributors may have to make an extra effort in some cases and send several PRs if we want the project to succeed.

Impact
======

NAPALM can be used in two major ways; directly on people's code or via a framework like [saltstack](https://saltstack.com/), [ansible](https://www.ansible.com/) or [stackstorm](https://stackstorm.com/).

### Frameworks

If you are using NAPALM as a user of a framework there will be no impact for you. We will work with them and take the necessary steps to make sure a smooth migration with no impact and no action to be taken from your side.

### Direct use

If you are using NAPALM in your own code there are two possibilities:

1. If you are **installing napalm fully** via the `napalm` package, i.e. `pip install napalm`:
    1. Before the merge make sure you pin the version to `<2`. You can easily do that by updating your `requirements.txt` with the string `napalm<2`. If you don't have a requirements file we encourage you to add one but you can always install napalm from the CLI with `pip install "napalm<2"`. Doing this will ensure nothing breaks for you.
    1. After the merge, you will have to remove the `<2` constrain and maybe adapt a few import paths. Don't worry, a few import paths is everything that might change. We will provide instructions to make this transition smoother later on.
1. If you are **installing napalm partially by installing individual drivers** via their respective packages, i.e. `napalm-eos`, `napalm-junos`, etc...:
    1. You won't have to do anything at all before the merge as those repos won't change.
    2. After the merge you will have to migrate to `napalm>2` and make some import path changes. If you still want to be able to install individual drivers, don't worry. We will provide a mechanism so you can continue doing so.

Timeline
========

The rough timeline is as follow:

* **Today**, start discussing with people behind salststack, trigger, stackstorm, etc... so they are aware of this.
* **D-Day, code freeze**. No new PRs are merged into `napalm-*`.
* **D-Day+1, beta release**. A beta version of the unified repo will be released for people to test.
* **D-Day+n, more betas** to follow. We will keep releasing betas as we find and fix issues.
* **D-Day+14, first version of `napalm`** is released. Instructions to ensure a simple migration will be provided too.

As we want to make sure people has time to update their requirements file to pin versions we have decided to set **D-Day** to **October 20th 2017**.

RFC
===

As previously stated, this is a rough plan, if you have concerns, comments, suggestions there a few ways you can reach to us to make them known:

1. We have create an [issue](https://github.com/napalm-automation/napalm/issues/392) on github.
2. You can also reach us on slack. For details about how to reach us on slack visit the [community](/community) section.
