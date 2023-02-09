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

When your team works heavily with TSOs, the TSO itself _de facto_ becomes part of the source of truth. Users can easily create orgs that match the requirements of the product! But - they no longer need to know or care what the requirements of the product _are_. That knowledge becomes lost inside the TSO, whose state is difficult to review and has limited history tracking.

Does your team know which licenses, features, and settings your product requires? The TSO knows, but it cannot tell you.

## TSO as Binary Blob

A "binary blob", in software engineering, refers to a component that cannot be inspected. It's provided only as an opaque binary. You can execute that binary to do work, but you cannot look inside it to see what makes it tick and how it's implemented.

Binary blobs pose a number of challenges in the SDLC. 

## TSO as Agility Blocker

TSOs can deliver only new orgs. There is no such thing as a modular TSO; you cannot layer a TSO on top of an existing org. That means that the effort cliff on composability is a vertical line.

Here's what I mean by this. Let's look at the lifespan of a product:

It starts on the left at inception, and delivers to customers via a TSO. That's great - it keeps effort nice and low, and we can serve customers and internal stakeholders with the same TSO-based artifacts.

The product evolves. You bring in a solution engineering team, and they've got their own ideas about how to set up the product to support demos and sales most effectively. You spin up a new TSO to support your demo orgs.

Meanwhile, Engineering keeps refining the product. They update the TSO each time they do a release to match the current known-good configuration of the product. But now, you've got two TSOs to update. Communication and ownership between Engineering and Solution Engineering start to become a challenge.

You make a big push and release Version 2 of the product. Your product grows by leaps and bounds, and many of the configurations you formerly recommended to customers are no longer valid. You 

The company's been acquired. That's great! The new ownership doubles down on your product line. Now, Massive Events will be serving multiple verticals, and needs to integrate with a suite of five other products to bring it to the highest level.

Whither the TSO? 

- Are you going to make five new TSOs, to represent the deliverable state of the product with each of those other applications?
- What about combinations of those five products? That could start to be a _lot_ of TSOs you're managing.
- What about Solution Engineering - will they still need their own, separate TSOs for demo configurations?

Suddenly your team, instead of updating _one_ org every release, is making the same changes in a dozen, or two dozen, orgs. There's essentially no way to share that work. You've just got to repeat it two dozen times. Humans make mistakes. Tight deadlines result in one-off changes in this org or that org. State drifts. The documentation does not match. You're spending tons of time that could be used to create customer value just updating all these damn orgs. And before long, you no longer have any clarity about how the product is actually meant to be delivered.

---

Maybe your story doesn't quite match this one. You don't get acquired. You have a single product. You grow it slowly, and you stick with one TSO. But your agility is still hampered! 

You build out a new, incremental release. It adds a really slick new feature, but the feature needs to be enabled by customers. That work takes a while - a few days of work for a skilled administrator. Your docs team write excellent content to enable admins, and your staff use that documentation to update the TSO. Now, new customers will start with that feature fully enabled and ready to use. They can realize the value on day 1.

... but what about your existing customers? They've already got customized orgs. They cannot use the TSO to get your pre-built enablement for this new feature. Their admins are stuck doing those days of work based on your documentation.

That's a shame. Is it a product-breaker? Probably not. But it means that you cannot deliver that value through any channel other than a brand-new customer org signup.

## Disaster Recovery



## Org Snapshots

Org Snapshots are much 

## TSOs and Org Snapshots as Operational Tool

## Source-Driven TSOs

I've said a lot against TSOs. Let me say one thing for them: TSOs work well for their core purpose, which is generating a new org for a user or customer. The `SignupRequest` API is simple to use and the process is effective.

We can consume that core function of the TSO without sacrificing our SDLC goals - without incurring all of the problems discussed above. We do that by using a _source-driven TSO_ model.