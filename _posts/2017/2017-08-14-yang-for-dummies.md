---
title: "YANG for dummies"
author: dbarrosop
description: "YANG for dummies"
tags: ["yang", "post"]
---

> I originally wrote this post as part of the documentation of [napalm-yang](https://github.com/napalm-automation/napalm-yang) but then I realized this post could be interesting for the general audience and not exclusively for people willing to try out that project.

This post tries to explain some of the general ideas of YANG, why is it interesting, how you can use it to describe data in a very convoluted but yet flexible and powerful way and, more interestingly, how it can be used.

Note that this is just an introduction, if you want to fully understand how YANG works I'd recommend reading [RFC6020](https://tools.ietf.org/html/rfc6020). For [napalm-yang](https://github.com/napalm-automation/napalm-yang), I'd recommend checking this [tutorial](https://github.com/napalm-automation/napalm-yang/blob/develop/interactive_demo/tutorial.ipynb).

## What is YANG

The *tl;dr;* version is that YANG is a data modelling language. It is used to describe how data is supposed to look. YANG is not XML or JSON, YANG is a language of it's own and it only describes data models. For individual instances of the data JSON or XML can be used.

<!--more-->


## Terminology

We are going to start with some terminology to make sure we all speak a common language. The following terminology is an extract of [RFC6020](https://tools.ietf.org/html/rfc6020) section 3.

*  **augment**: Adds new schema nodes to a previously defined schema
   node.

*  **container**: An interior data node that exists in at most one
   instance in the data tree.  A container has no value, but rather a
   set of child nodes.

*  **data model**: A data model describes how data is represented and
   accessed.

*  **data node**: A node in the schema tree that can be instantiated in a
   data tree.  One of container, leaf, leaf-list, list, and anyxml.

*  **data tree**: The instantiated tree of configuration and state data
   on a device.

*  **derived type**: A type that is derived from a built-in type (such as
   uint32), or another derived type.

*  **device deviation**: A failure of the device to implement the module
   faithfully.

*  **grouping**: A reusable set of schema nodes, which may be used
   locally in the module, in modules that include it, and by other
   modules that import from it.  The grouping statement is not a data
   definition statement and, as such, does not define any nodes in
   the schema tree.

*  **identifier**: Used to identify different kinds of YANG items by
   name.

*  **leaf**: A data node that exists in at most one instance in the data
   tree.  A leaf has a value but no child nodes.

*  **leaf-list**: Like the leaf node but defines a set of uniquely
   identifiable nodes rather than a single node.  Each node has a
   value but no child nodes.

*  **list**: An interior data node that may exist in multiple instances
   in the data tree.  A list has no value, but rather a set of child
   nodes.

*  **module**: A YANG module defines a hierarchy of nodes that can be
   used for NETCONF-based operations.  With its definitions and the
   definitions it imports or includes from elsewhere, a module is
   self-contained and "compilable".

*  **state data**: The additional data on a system that is not
   configuration data such as read-only status information and
   collected statistics [RFC4741].

## Star Wars Universe

Let's try to understand YANG a bit better by using an example. Imagine for a second you want to write the ultimate Star Wars framework; one framework to rule them all (wrong movie).

To begin with, we want to start by being able to add individuals from the Star Wars universe into a list. Those individuals will have the following information:

* **name**, everybody has a name, even if it's a model number. Nothing we really have to do here. A name is just a string.

* **age**, which we will be limit to 2000, because who wants to live forever (wrong movie again). To support the age we are going to create a new type that we will use to enforce the correctness of the data:

``` yang
typedef age {
  type uint16 {
    range 1..2000;
  }
}
```

* **affiliation**, you are either with the empire or against it. For the affiliation we are going to create an identity that will unequivocally identify each possible affiliation:

``` yang
identity AFFILIATION {
  description "To which group someone belongs to";
}

identity EMPIRE {
  base AFFILIATION;
  description "Affiliated to the empire";
}

identity REBEL_ALLIANCE {
  base AFFILIATION;
  description "Affiliated to the rebel alliance";
}
```

Now that we have set the foundation, let's create the model:

``` yang
// module name
module napalm-star-wars {

    // boilerplate
    yang-version "1";
    namespace "https://napalm-yang.readthedocs.io/napalm-star-wars";

    prefix "napalm-star-wars";

    // identity to unequivocally identify the faction an individual belongs to
    identity AFFILIATION {
      description "To which group someone belongs to";
    }

    identity EMPIRE {
      base AFFILIATION;
      description "Affiliated to the empire";
    }

    identity REBEL_ALLIANCE {
      base AFFILIATION;
      description "Affiliated to the rebel alliance";
    }

    // new type to enforce correctness of the data
    typedef age {
      type uint16 {
        range 1..2000;
      }
    }

    // this grouping will all the personal data we will assign to individuals
    grouping personal-data {
        leaf name {
            type string;
        }
        leaf age {
            type age;
        }
        leaf affiliation {
            type identityref {
                base napalm-star-wars:AFFILIATION;
            }
        }
    }

    // this is the root object defined by the model
    container universe {
        list individual {
            // identify each individual by using the name as key
            key "name";

            // each individual will have the elements defined in the grouping
            uses personal-data;
        }
    }
}
```

First we have some metadata, the identity we created for the affiliation and the age type. Then we are creating a grouping where we group the personal data we want for each individual and finally we just need a container to create a list of individuals. Note we will use the name of each individual as the key element.

### Using the Model

Now let's try to represent the model in a tree format:

``` shell
$ pyang -f tree napalm-star-wars.yang
module: napalm-star-wars
    +--rw universe
        +--rw individual* [name]
           +--rw name           string
           +--rw age?           age
           +--rw affiliation?   identityref
```


Make sense, it's what we were expecting. Now, let's make something useful with it and build python code from the model. We can use ``pyangbind`` for that (the lib ``napalm-yang`` uses under the hoods):

``` shell
$ export PYBINDPLUGIN=`/usr/bin/env python -c \
        'import pyangbind; import os; print "%s/plugin" % os.path.dirname(pyangbind.__file__)'`
$ pyang --plugindir $PYBINDPLUGIN -f pybind napalm-star-wars.yang > napalm_star_wars.py
```

Now we have some python code we can put to test:

``` python
>>> import napalm_star_wars
>>>
>>> sw = napalm_star_wars.napalm_star_wars()
>>>
>>> obi = sw.universe.individual.add("Obi-Wan Kenobi")
>>> obi.affiliation = "REBEL_ALLIANCE"
>>> obi.age = 57
>>>
>>> luke = sw.universe.individual.add("Luke Skywalker")
>>> luke.affiliation = "REBEL_ALLIANCE"
>>> luke.age = 19
>>>
>>> darth = sw.universe.individual.add("Darth Vader")
>>> darth.affiliation = "EMPIRE"
>>> darth.age = 42
>>>
>>> yoda = sw.universe.individual.add("Yoda")
>>> yoda.affiliation = "REBEL_ALLIANCE"
>>> yoda.age = 896
>>>
>>> import json
>>> print(json.dumps(sw.get(), indent=4))
{
    "universe": {
        "individual": {
            "Obi-Wan Kenobi": {
                "affiliation": "REBEL_ALLIANCE",
                "age": 57,
                "name": "Obi-Wan Kenobi"
            },
            "Luke Skywalker": {
                "affiliation": "REBEL_ALLIANCE",
                "age": 19,
                "name": "Luke Skywalker"
            },
            "Darth Vader": {
                "affiliation": "EMPIRE",
                "age": 42,
                "name": "Darth Vader"
            },
            "Yoda": {
                "affiliation": "REBEL_ALLIANCE",
                "age": 896,
                "name": "Yoda"
            }
        }
    }
}
```

Cool, now let's try to create Boba Fett:

``` python
>>> boba = sw.universe.individual.add("Boba Fett")
>>> boba.affiliation = "MERCENARY"
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "napalm_star_wars.py", line 165, in _set_affiliation
    'generated-type': """YANGDynClass(base=RestrictedClassType(base_type=unicode, restriction_type="dict_key", restriction_arg={u'napalm-star-wars:EMPIRE': {'@namespace': u'https://napalm-yang.readthedocs.io', '@module': u'napalm-star-wars'}, u'EMPIRE': {'@namespace': u'https://napalm-yang.readthedocs.io', '@module': u'napalm-star-wars'}, u'napalm-star-wars:REBEL_ALLIANCE': {'@namespace': u'https://napalm-yang.readthedocs.io', '@module': u'napalm-star-wars'}, u'REBEL_ALLIANCE': {'@namespace': u'https://napalm-yang.readthedocs.io', '@module': u'napalm-star-wars'}},), is_leaf=True, yang_name="affiliation", parent=self, path_helper=self._path_helper, extmethods=self._extmethods, register_paths=True, namespace='https://napalm-yang.readthedocs.io', defining_module='napalm-star-wars', yang_type='identityref', is_config=True)""",
ValueError: {'error-string': 'affiliation must be of a type compatible with identityref', 'generated-type': 'YANGDynClass(base=RestrictedClassType(base_type=unicode, restriction_type="dict_key", restriction_arg={u\'napalm-star-wars:EMPIRE\': {\'@namespace\': u\'https://napalm-yang.readthedocs.io\', \'@module\': u\'napalm-star-wars\'}, u\'EMPIRE\': {\'@namespace\': u\'https://napalm-yang.readthedocs.io\', \'@module\': u\'napalm-star-wars\'}, u\'napalm-star-wars:REBEL_ALLIANCE\': {\'@namespace\': u\'https://napalm-yang.readthedocs.io\', \'@module\': u\'napalm-star-wars\'}, u\'REBEL_ALLIANCE\': {\'@namespace\': u\'https://napalm-yang.readthedocs.io\', \'@module\': u\'napalm-star-wars\'}},), is_leaf=True, yang_name="affiliation", parent=self, path_helper=self._path_helper, extmethods=self._extmethods, register_paths=True, namespace=\'https://napalm-yang.readthedocs.io\', defining_module=\'napalm-star-wars\', yang_type=\'identityref\', is_config=True)', 'defined-type': 'napalm-star-wars:identityref'}
```

Turns out our model only accounts for rebels and members of the empire. It's alright, isn't it?

## Star Wars Extended Universe

So our framework has been a success, so much that people has started adding mods to it. One of those mods adds support for individuals working as mercenaries and it also adds an extra piece of information into the personal data of each individual to indicate if the individual is in active duty or retired.

YANG is quite powerful when it comes to extending existing models; you don't really need to fork the project, change the schema or do anything crazy. You just import the old model and add new stuff. So let's see how the extension to our existing model would look like:

``` yang
module napalm-star-wars-extended {

    yang-version "1";
    namespace "https://napalm-yang.readthedocs.io/napalm-star-wars-extended";

    prefix "napalm-star-wars-extended";

    // We import the old model
    import napalm-star-wars { prefix napalm-star-wars; }

    // New identity based off the old AFFILIATION
    identity MERCENARY {
        base napalm-star-wars:AFFILIATION;
        description "Friend for money";
    }

    // This grouping contains the new information we want to attach
    // to the personal data of the old model
    grouping extended-personal-data {
        leaf status {
            type enumeration {
                enum ACTIVE {
                    description "In active duty";
                }
                enum RETIRED {
                    description "Enjoying retirement, probably in a house by a lake";
                }
            }
        }
    }

    // This is where we tell what part of the old model we want to extend
    augment "/napalm-star-wars:universe/napalm-star-wars:individual" {
        uses extended-personal-data;
    }
}
```

Easy, right? Beauty is that you can load the extensions if you want and if someone do changes in the original model you will benefit from them as you didn't fork the model. Now let's do the same we did before and see how we can take advantage of the extensions.

The tree representation looks good:

``` shell
$ pyang -f tree napalm-star-wars-extended.yang napalm-star-wars.yang
module: napalm-star-wars
    +--rw universe
       +--rw individual* [name]
          +--rw name                                string
          +--rw age?                                age
          +--rw affiliation?                        identityref
          +--rw napalm-star-wars-extended:status?   enumeration
```

Now let's create some code with the extensions in place:

```
$ pyang --plugindir $PYBINDPLUGIN -f pybind napalm-star-wars-extended.yang napalm-star-wars.yang > napalm_star_wars_extended.py
```

And use it:

``` python
>>> import napalm_star_wars_extended
>>>
>>> sw = napalm_star_wars_extended.napalm_star_wars()
>>>
>>> obi = sw.universe.individual.add("Obi-Wan Kenobi")
>>> obi.affiliation = "REBEL_ALLIANCE"
>>> obi.age = 57
>>> obi.status = "RETIRED"
>>>
>>> darth = sw.universe.individual.add("Darth Vader")
>>> darth.affiliation = "EMPIRE"
>>> darth.age = 42
>>> darth.status = "ACTIVE"
>>>
>>> yoda = sw.universe.individual.add("Yoda")
>>> yoda.affiliation = "REBEL_ALLIANCE"
>>> yoda.age = 896
>>> yoda.status = "RETIRED"
>>>
>>> boba = sw.universe.individual.add("Boba Fett")
>>> boba.affiliation = "MERCENARY"
>>> boba.age = 32
>>> boba.status = "ACTIVE"
>>>
>>> import json
>>> print(json.dumps(sw.get(), indent=4))
{
    "universe": {
        "individual": {
            "Obi-Wan Kenobi": {
                "status": "RETIRED",
                "affiliation": "REBEL_ALLIANCE",
                "age": 57,
                "name": "Obi-Wan Kenobi"
            },
            "Darth Vader": {
                "status": "ACTIVE",
                "affiliation": "EMPIRE",
                "age": 42,
                "name": "Darth Vader"
            },
            "Yoda": {
                "status": "RETIRED",
                "affiliation": "REBEL_ALLIANCE",
                "age": 896,
                "name": "Yoda"
            },
            "Boba Fett": {
                "status": "ACTIVE",
                "affiliation": "MERCENARY",
                "age": 32,
                "name": "Boba Fett"
            }
        }
    }
}
```

Great, we now know if the individual is enjoying a golden retirement or not and we also support an extra faction in our extended version of the framework.

## A Real life example

Now let's see how ``napalm-yang`` actually takes advantage of the extensibility of YANG. If you take a look to the [openconfig-if-ip](https://github.com/openconfig/public/blob/master/release/models/interfaces/openconfig-if-ip.yang) model you will realize it doesn't support the ``secondary`` option that some platforms require when configuring multiple IPv4 addresses on the same interface. Well, not a huge deal, we can fix it ourselves:

``` yang
module napalm-if-ip {
    yang-version "1";

    namespace "https://github.com/napalm-automation/napalm-yang/yang_napalm/interfaces";

    prefix "napalm-ip";

    import openconfig-interfaces { prefix oc-if; }
    import openconfig-vlan { prefix oc-vlan; }
    import openconfig-if-ip { prefix oc-ip; }

    organization "NAPALM Automation";

    contact "napalm-automation@googlegroups.com";

    description "This module defines some augmentations to the interface's IP model of OC";

    revision "2017-03-17" {
      description
        "First release";
      reference "1.0.0";
    }

    grouping secondary-top {
        description "Add secondary statement";

        leaf secondary {
            type boolean;
            default "false";

            description
            "Most platforms need a secondary statement on when configuring multiple IPv4
            addresses on the same interfaces";

            reference "https://www.cisco.com/c/en/us/td/docs/ios/12_2/ip/configuration/guide/fipr_c/1cfipadr.html#wp1001012";
        }
    }

    augment "/oc-if:interfaces/oc-if:interface/" +
        "oc-if:subinterfaces/oc-if:subinterface/" +
        "oc-ip:ipv4/oc-ip:addresses/oc-ip:address/" +
        "oc-ip:config" {
        description "Add secondary statement to subinterfaces' IPs";

        uses secondary-top;
    }

    augment "/oc-if:interfaces/oc-if:interface/" +
        "oc-vlan:routed-vlan/" +
        "oc-ip:ipv4/oc-ip:addresses/oc-ip:address/" +
        "oc-ip:config" {
        description "Add secondary statement to routed VLANs' IPs";

        uses secondary-top;
    }
}

```
