---
layout: post
title: The Bridge Package Pattern
---


Managing your package architecture for a Salesforce platform product is a major challenge not because it's difficult as such, but because in many cases your decisions must be made very early in the lifecycle of the product and are very difficult or even impossible to change. This challenge is especially prominent when designing extension packages, which build upon existing managed packages. The bridge package pattern is a package architecture that factors dependency into a tiny, minimal second package whose only job is connecting two other packages that are independent of one another. Think of it like a junction object for managed packages.

The bridge package pattern can be counterintuitive, but offers long-term value. We'll explore it through an example product called Massive Events.

## The Bridge Package Pattern

Understanding the value of the bridge package pattern requires that we get into the weeds of managed package dependency and manageability rules. Let's dig in to how this plays out in the journey of Massive Events from product design to delivery. 

At Massive Events, you're building a new managed package product to help organize galas, fundraising events, and classes. Integration with the Nonprofit Success Pack (NPSP) is a key objective for your product: nonprofit customers will need to connect event income to General Accounting Units, apply Action Plans to event attendees, and cultivate participants through a donor pipeline. 

Naturally, you envision your product as an _extension package_ of NPSP. An extension package includes components that directly reference components of another ("core") package, meaning that installation of the extension package will always require the core package. Massive Events will add schema to NPSP objects, establish relationships between Massive Events objects and NPSP objects, and call `global` methods in NPSP's Apex classes. Here's what the package architecture looks like.

![Extension package architecture](/assets/images/MassiveEventsPackages.png)

This design is _not wrong_. Extending managed packages to provide new functionality is a common and valuable strategy for developing an AppExchange product; it encourages end users to compose multiple products to cover the full breadth of their needs. But here's the low-level technical blocker that can ultimately make this architectural choice dangerous: _in a subset of cases that is challenging to define completely, it is impossible to remove a dependency between an extension package and its core package_. 

The dependency between Massive Events and NPSP is established by the points of connection between components we mentioned above. When Massive Events Apex calls NPSP Apex, that's a dependency. Likewise, when Massive Events adds schema to NPSP objects or references those objects in its own schema, another dependency is created. Once those component-to-component dependencies exist, they're under the control of the _manageability rules_ applied to the components in the extension package that reference the core package. If manageability rules don't allow the package developer to change or delete the component that contains the cross-package reference, the dependency is permanent. 

The upshot of all this is that Massive Events may _always_ require the Nonprofit Success Pack, in every customer org. And whether or not that's the case is determined by innocuous technical decisions made during implementation, like whether or not to reference an NPSP component in a Flow (which cannot be deleted).

Now, Massive Events might say "So what? We're a nonprofit-focused product; requiring NPSP is not a problem for our package". And that's fine. But it's a long-term business risk that the company must evaluate. What if their clients start asking to buy Massive Events for EDA? Or Massive Events for a vanilla Sales Cloud org? Massive Events could be leaving long-term revenue on the table by designing their package in a way that won't allow them to pivot, or incurring significant costs if they need to maintain multiple copies of the same codebase to support these divergent customer bases.

## Building Bridges

The solution to this challenge is the _bridge package pattern_. It's a way of structuring the application into packages in a way that allows Massive Events to isolate their dependency on NPSP from the core functionality of their package into a separate _bridge_, leaving the door open to later pivoting the core application to support other types of Salesforce org.

The package structure for Massive Events would look like this under the bridge package approach:

![Package architecture with bridges](/assets/images/MassiveEventsWithBridges.png)

Massive Events itself has _no_ dependencies, and contains only the core functionality of the application. 

A great example of the bridge package pattern is [Outbound Funds Module](https://github.com/SalesforceFoundation/OutboundFundsModule) (OFM). OFM helps organizations that disburse grant funds track their operations. It supports the Nonprofit Success Pack, but doesn't require it, because it's structured with a bridge package just like the one shown above for Massive Events. Since Outbound Funds Module is open source, you can check out how both it and its [NPSP bridge package](https://github.com/SalesforceFoundation/OutboundFundsModuleNPSP) are designed.

---

Dividing package functionality into a core and a bridge can seem unnatural, especially for products that are deeply connected to the package to which you wish to bridge. In some cases, your core package won't be functional by itself: it will require at least one bridge package. For example, the Massive Events Flows we mentioned above require NPSP, and without them, some of Massive Events' functionality won't work at all. A Massive Events customer would need to install the core Massive Events package _plus_ the NPSP bridge, or the EDA bridge, or a bridge for vanilla Sales Cloud, since those Flows cannot live in the core package. 

Similarly, an NPSP extension like Massive Events might need to _either_ interoperate with the NPSP Table Driven Trigger Management framework _or_ use its own trigger framework if NPSP is not present. As the package architect, you could site the TDTM integration in the NPSP bridge, and either ship the Massive Events trigger framework in a Sales Cloud bridge or include it in the core application with a feature flag to inactivate it when NPSP is present. Both frameworks would call the same Apex classes in the core application to execute work, leaving mostly glue code in the bridges.

The Massive Events core package includes as much of the application schema as possible. This decision is particularly helpful for API consumers and integrated applications: regardless of the shape of the org overall, API clients like data loaders and enterprise services can rely on the Massive Events schema having the same shape. Relationships between Massive Events schema and NPSP objects, and fields added by Massive Events to NPSP, live in bridge packages.

## Development on complex bridge ecosystems

## What if you need a bridge and don't have one?

Earlier, we noted that

> ... in a subset of cases that is challenging to define completely, it is impossible to remove a dependency between an extension package and its core package.

There _are_ situations where removing this dependency is possible. I've done it in a production package! Whether or not it's possible is highly situation-dependent, and the procedure for executing the removal can impact current customers.