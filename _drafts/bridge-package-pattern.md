---
layout: post
title: The Bridge Package Pattern
---


Managing your package architecture for a Salesforce platform product is a major challenge not because it's difficult as such, but because in many cases your decisions must be made very early in the lifecycle of the product and are very difficult or even impossible to change. This challenge is especially prominent when designing extension packages, which build upon existing managed packages.

## The Bridge Package Pattern

Understanding the value of the bridge package pattern requires that we get into the weeds of managed package dependency and manageability rules. Let's tackle this by way of an example, starting with product design and exploring the implications for the application's lifecycle in customer orgs. 

At Massive Events, you're building a new managed package product to help nonprofits organize galas, fundraising events, and classes. Integration with the Nonprofit Success Pack (NPSP) is a key objective for your product: customers will need to connect event income to General Accounting Units, apply Action Plans to event attendees, and more. 

Naturally, you envision your product as an _extension package_ of NPSP. An extension package includes components that directly reference components of another ("core") package, meaning that installation of the extension package will always require the core package. Massive Events will add schema to NPSP objects, establish relationships between Massive Events objects and NPSP objects, and call `global` methods in NPSP's Apex classes.

This design is _not wrong_. Extending managed packages to provide new functionality is a common and valuable strategy for developing an AppExchange product; it encourages end users to compose multiple products to cover the full breadth of their needs. But here's the low-level technical blocker that can ultimately make this architectural choice dangerous: _in many cases, it is impossible to remove a dependency between an extension package and its core package_. 

The dependency between Massive Events and NPSP is established by the points of connection between components we mentioned above. When Massive Events Apex calls NPSP Apex, that's a dependency. Likewise, when Massive Events adds schema to NPSP objects or references those objects in its own schema, another dependency is created. Once those component-to-component dependencies exist, they're under the control of the _manageability rules_ applied to the components in the extension package that reference the core package.

The upshot of all this is that Massive Events will _always_ require the Nonprofit Success Pack, in every customer org.

Now, Massive Events might say "So what? We're a nonprofit-focused product; requiring NPSP is not a problem for our package". And that's fine.
