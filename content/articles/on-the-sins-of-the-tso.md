+++
title="On the Problems with TSOs"
draft=true
+++

## Introduction to TSOs

One of the most common methods of distributing Salesforce orgs and packages is the _TSO_: a _Trialforce Source Org_.

At the simplest, a TSO is a Salesforce org that you can copy. You install a product, set up all of the configuration, add sample data, and perform whatever other customization you wish. Then, you take a _snapshot_ of that org (using the Setup->Trialforce UI). The snapshot captures the complete state of that org at a point in time. You can have many snapshots over the evolution of the TSO's state.

Once you have a snapshot, you can perform _signups_ against it. The `SignupRequest` API allows you to request a _new_ Salesforce org, whose state starts from a specific TSO snapshot. You pass the API the `0TT` id of your snapshot, and you get back authentication information for your new org. Where the _trial_ part of _Trialforce_ comes in is that that new org has a fixed lifespan, after which it has to be converted to a production org (or disposed). 30 days is a common trial length, but it's not mandatory.

You can also use Environment Hub in a Partner Business Org to sign up copies of the TSO. These orgs aren't necessarily time-limited. (TODO: true?)

This functionality might sound quite nice. And in some ways, it is! TSOs are very effective at delivering copies of whole Salesforce orgs, including configuration that is very time-consuming to set up from scratch. But there are a number of patterns in how TSOs are used that have deep negative effects on the software development and delivery lifecycle. My purpose in this article is to explore those negative effects and show you how to avoid them.

## Use Cases

- Customer delivery
- QA
- License replication

## The Source-of-Truth Problem

Modern development projects focus on version control as the _source of truth_: the canonical definition of what's in your product. But TSOs blur that line. If y

## Knowledge Limitation

A corollary to the source-of-truth problem is _knowledge limitation_.

When your team works heavily with TSOs, the TSO itself _de facto_ becomes part of the source of truth. 

## TSO as Binary Blob

A "binary blob", in software engineering, refers to a component that cannot be inspected. It's provided only as an opaque binary. You can execute that binary to do work, but you cannot look inside it to see what makes it tick and how it's implemented.

Binary blobs pose a number of challenges in the SDLC. 

## TSO as Agility Blocker

TSOs can deliver only new orgs. There is no such thing as a modular TSO; you cannot layer a TSO on top of an existing org. That means that the effort cliff on composability is a vertical line.

## Disaster Recovery



## Org Snapshots

Org Snapshots are much 

## TSOs and Org Snapshots as Operational Tool

## Source-Driven TSOs

I've said a lot against TSOs. Let me say one thing for them: TSOs work well for their core purpose, which is generating a new org for a user or customer. The `SignupRequest` API is simple to use and the process is effective.

We can consume that core function of the TSO without sacrificing our SDLC goals - without incurring all of the problems discussed above. We do that by using a _source-driven TSO_ model.