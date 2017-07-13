---
title: "Reunification"
layout: "post"
tags: ["news"]
---

Having an individual repo for each driver is causing a lot of administrative overhead so we have decided to merge all repos into a single one. This has some implications you may have to address before and after this happens so I am going to try summarize them here:

1. If you are **installing napalm fully** via the `napalm` package, ie `pip install napalm`:
    1. Before the merge make sure you pin the version to `<2`. You can easily do that by updating your `requirements.txt` with the string `napalm<2`. If you don't have a requirements file `pip install "napalm<2"` will do the trick. Doing this will ensure nothing breaks for you.
    1. After the merge, you will have to remove the `<2` constrain and adapt a few import paths. Don't worry, a few import paths is everything that will change. We will provide instructions to make this transition smoother.
1. If you are **installing napalm partially by installing individual drivers** via their respective packages, i.e. `napalm-eos`, `napalm-junos`, etc...:
    1. You won't have to do anything at all before the merge as those repos won't change.
    2. After the merge you will have to migrate to `napalm>2` and make some import path changes. If you still want to be able to install individual drivers, don't worry. We will provide a mechanism so you can continue doing so. We will provide further instructions soon [(example)](https://stackoverflow.com/questions/19096155/setuptools-and-pip-choice-of-minimal-and-complete-install).

Important dates:

* **Today**, start discussing with people behind salststack, trigger, stackstorm, etc... so they are aware of this.
* **D-Day, code freeze**. No new PRs are merged into `napalm-*`.
* **D-Day+1, beta release**. A beta version of the unified repo will be released for people to test.
* **D-Day+n, more betas** to follow. We will keep releasing betas as we find and fix issues.
* **D-Day+14, first version of `napalm`** is released. Instructions to ensure a simple migration will be provided too.
