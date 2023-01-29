+++
title="All About Connected Apps"
draft=true
+++

## What are Connected Apps?

Unlike the vast majority of metadata you'll interact with on the Salesforce platform, Connected Apps are _global metadata_. They're not scoped to a single org. A Connected App is created in a single org, but then become available in _any_ org to support authentication there.

## Types of Interaction

There are at least three situations where you'll need to interact with Connected Apps, and the workflows and objectives differ substantially between the three.

If you're an **org admin**, you'll work with Connected Apps primarily as you manage external integrations. 

If you're an **application developer**, you'll work with Connected Apps that you own

If you're a **systems integrator**, you'll work with a mix of Connected Apps that you own and Connected Apps owned by your integrated systems.

### Key Facets

- Client Id
- Client Secret
- Digital Certificate
- Policies
- Callback URL

### How Connected Apps Work

### Understanding Deployment and Installation


## Where Do I Go To Interact?

There's a bewildering variety of interaction points in Salesforce Setup for working with Connected Apps.

### Installing in an Org and Managing Installation

### Editing Policies

Once you're in App Manager, you'll see a list of Connected Apps. 

Note that some apps are listed as `Connected (Managed)` and others as `Connected`. The note `(Managed)` means that this Connected App is _installed_ in your org, but your org doesn't own the app. Your org does own the apps that have the `App Type` shown as `Connected`.

That distinction of ownership controls what access you have to the app's details. For apps you own, you can change and view any aspect of the app, including secrets like the Client Secret and the Digital Certificate. For managed apps, you can only change the _policies_ associated with it in your org: which users are approved to use that app, in particular.

### Managing the Connected App Itself

## Installing a Connected App in an Org

## Troubleshooting Connected App Errors

It's an important security principle never to disclose information that you do not have to disclose. This principle is doubly important in authentication-related contexts, where an attacker may use access attempts to probe a system and seek to acquire information that may be exploited.

Unfortunately, the application of this principle to OAuth authentication flows using Connected Apps means that engineers working on integration receive _almost no details_ when they encounter access issues. It often seems like _any_ mistake in setting up the Connected App or attempting authentication against it results in the same three error messages, none of which tell you what's actually wrong! As a result, troubleshooting Connected App issues is often an exercise in frustration.
