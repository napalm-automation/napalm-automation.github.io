---
title: "Reunification beta announcement"
author: dbarrosop
description: "New napalm with all the unified drivers is in beta. Come and check it out."
tags: ["news"]
---

As we announced in a [previous post](/reunification/) we have unified all of our core drivers under the same [napalm repo](https://github.com/napalm-automation/napalm). Right now, we have released a beta version which we hope you can help us testing. To do so just run the following ``pip`` command:

```
pip install --pre napalm  # --pre is only necessary while this is in beta
```

<!--more-->

## Drivers: core and community efforts

Until now we have treated all drivers equal but the truth is that they weren't. In the core group, we have been focusing in a bunch of drivers for various reasons. In the meantime, other drivers, for which we didn't have a vested interest or the expertise, haven't gotten the attention they deserved. Not only that, the lack of expertise on those drivers and the need the project had for us to integrate them was both slowing down the development of those drivers and the development of other features as the core group had to try to understand those drivers to review, integrate and release.

With this reunification we are going to try to address those issues and hopefully allow those drivers to thrive under the expertise of the community without the need for us to police them. We will formalize this in the documentation soon but in the meantime here is a taste of what's coming.

### core drivers

These are drivers for which the core group considers itself responsible of and for which we will provide bugfixes, new features and for which we will review PRs sent by the community. Nothing much changes here as a matter of fact. Drivers under this category are:

* ``eos``
* ``ios``
* ``iosxr``
* ``junos``
* ``nxos``
* ``nxos_ssh``

These drivers will be available under the unified ``napalm`` repo.

### community drivers

These are drivers that the core group won't be directly responsible of. Instead, they will be maintained by the community. What does this mean? For starters they will live under a dedicated repo, for instance, ``napalm-ros``. That repo will be directly under the supervision of one ore more individuals that belong to the community. Those individuals will have full write access to it and, thus, will be responsible for bugfixes, new features, reviewing PRs, etc...

Current community drivers are:

* ``fortios``
* ``pluribus``
* ``panos``
* ``ros``
* ``vyos``
* ``cumulus``

## Code compatibility

New "unified" napalm should be backwards compatible with no change whatsoever. However, there a few exceptions where minor adaptations have to be made that I will detail a continuation.

> If you don't know what I mean you are probably not affected.

1. Your code was installing specific drivers rather than just ``napalm``.
2. Your code was importing directly from drivers or from ``napalm_base``.

### Installing specific drivers

Specific drivers used to be installed like this:

```
pip install napalm-eos
pip install napalm-junos
```

The new way of installing drivers is:

* **core drivers**:

```
# --pre is only needed while "reunification" is in beta
pip install napalm --pre --install-option="eos" --install-option="junos"
```

If you want to add a new drivers to an existing installation:

```
pip install --pre --install-option="ios" --force-reinstall -U napalm
```

* **community drivers** are installed as before:


```
pip install napalm-ros
```

## Adapting imports

> Following instructions only concern core drivers.

Most people won't need to adapt anything but if you were importing directly from ``napalm_base`` and/or a driver, you will have to do a simple change; replace the ``_`` in ``napalm_base`` or ``napalm_$driver`` with a dot, for instance ``from napalm_base import blah`` to ``from napalm.base import bleh`` or ``from napalm_ios import blah`` to ``from napalm.ios import blah``. As simple as that.

A continuation here is a few commands you can run in the root of your project to fix this for you.

* macos:

```
find . -type f -exec sed -i '' 's/napalm_base/napalm\.base/g' {} \;
find . -type f -exec sed -i '' 's/napalm_eos/napalm\.eos/g' {} \;
find . -type f -exec sed -i '' 's/napalm_ios/napalm\.ios/g' {} \;
find . -type f -exec sed -i '' 's/napalm_iosxr/napalm\.iosxr/g' {} \;
find . -type f -exec sed -i '' 's/napalm_junos/napalm\.junos/g' {} \;
find . -type f -exec sed -i '' 's/napalm_nxos/napalm\.nxos/g' {} \;

```

* linux:

```
find . -type f -exec sed -i 's/napalm_base/napalm\.base/g' {} \;
find . -type f -exec sed -i 's/napalm_eos/napalm\.eos/g' {} \;
find . -type f -exec sed -i 's/napalm_ios/napalm\.ios/g' {} \;
find . -type f -exec sed -i 's/napalm_iosxr/napalm\.iosxr/g' {} \;
find . -type f -exec sed -i 's/napalm_junos/napalm\.junos/g' {} \;
find . -type f -exec sed -i 's/napalm_nxos/napalm\.nxos/g' {} \;
```

## Pinning napalm

If you want to pin napalm's version to ensure you are using the old drivers while you review your code you can do so by pinning your code to use ``napalm<2``.
