+++
title="On the Problems with TSOs"
draft=true
+++

## Introduction to TSOs

One of the most common methods of distributing Salesforce orgs and packages is the _TSO_: a _Trialforce Source Org_.

At the simplest, a TSO is a Salesforce org that you can copy. You install a product, set up all of the configuration, add sample data, and perform whatever other customization you wish. Then, you take a _snapshot_ of that org (using the Setup->Trialforce UI). The snapshot captures the complete state of that org at a point in time. You can have many snapshots over the evolution of the TSO's state.

Once you have a snapshot, you can perform _signups_ against it. The `SignupRequest` API allows you to request a _new_ Salesforce org whose state starts from a specific TSO snapshot. You pass the API the `0TT` id of your snapshot, and you get back authentication information for your new org. Where the _trial_ part of _Trialforce_ comes in is that that new org has a fixed lifespan, after which it has to be converted to a production org (or disposed). 30 days is a common trial length, but it's not universal.

You can also use Environment Hub in a Partner Business Org to sign up copies of the TSO. These orgs aren't necessarily time-limited. (TODO: true?)

This functionality might sound quite nice. And in some ways, it is! TSOs are very effective at delivering copies of whole Salesforce orgs, including configuration that is very time-consuming to set up from scratch. But there are a number of patterns in how TSOs are used that have deep negative effects on the software development and delivery lifecycle. My purpose in this article is to explore those negative effects and show you how to avoid them. Thoughout, I'll use an imaginary development team building a managed package-based product called Massive Events.

With that basic statement of TSO capability in mind, let's look at some key TSO use cases, running the gamut from internal to customer-facing to partner support.

### Engineering 

### QA, PM, and Other Stakeholders

### Partners

### Customer Delivery

### Conclusions


## Part 1: How TSOs Fail Your SDLC

> Thesis: TSOs divide the source of truth for the product.

Modern development projects focus on version control as the _source of truth_. Your version control repository (usually, but not always, Git) is the canonical definition of what makes up your product, and it's the operational hub of your software development lifecycle (SDLC). Version control comes with a litany of benefits I won't evangelize in any detail here.

When you introduce a TSO into your product development, the source of truth becomes ambiguous. Here's a failure case.

<TODO: development story>

---

> Thesis: Most TSO-based development is inherently noncompliant.

Compliance processes often focus heavily on version control. Git, combined with your system of record for tracking work, forms an audit log. It tells the story of how your product got to where it was: who made what change, why they made it, and who signed off to approve the change. TSOs make it difficult or impossible to answer those three questions. 

The Massive Events is going through their annual compliance audit. This year, they've engaged a new auditing firm, and the auditors haven't worked on Salesforce-based products before. They dig into the Massive Events release process, and think they understand how new customers are onboarded.

1. The development team releases a managed package version. The release is done by a release engineer, after signoff by a quality engineer. The release work is tracked in a ticketing system.
    a. The auditors nod, and make notes. They understand this paradigm.
1. The product manager logs into the TSO and installs the new package version. They update some Page Layouts and Profiles to reflect the new version, and walk through the user experience to make sure everything looks right. If there's an issue, they fix it along the way.
    a. "Where is this work tracked?" the auditor asks. "Who approves it?"
1. The product manager creates a new TSO snapshot and enables it for customer signup.
    a. The auditor starts to look concerned. "Isn't this the actual release? Who signs off on this artifact?"
1. The product manager has the only login to the TSO.
    a. The auditor looks _very_ concerned. "What if the product manager were a bad actor? They could deliver anything in the TSO, even malicious code."

Is using a TSO a genuine risk to an audit, given a clever enough auditor? I have no idea. I'm not an expert on the complexities of SOC2 and the like. Could you mitigate these risks with appropriate process enhancements? Yes, you could. But I think it's clear that TSO-based development _as it's often done_ - in-org, outside the context of a well-defined SDLC - absolutely violates the spirit of many audit goals. It's not trackable in version control. It is likely not reviewed and approved by a distinct member of the team. And there are limited tools (the Setup Audit Trail) to understand and evaluate changes made in the org. 

All of those core capabilities are built in to every version control system under the sun.

Whether or not these process shortfalls are actually of concern to auditors, they should absolutely be of concern to anyone who has an eye on the underlying goals of audit and compliance processes. 

## Part 2: How TSOs Fail Your Team

> Thesis: TSOs inhibit teams from socializing critical knowledge about the product and how it works.

A corollary to the source-of-truth problem is _knowledge limitation_.

When your team works heavily with TSOs, the TSO itself _de facto_ becomes part, not just of your source of truth, but of your knowledge base about the product and how it works. Users can easily create orgs that match the requirements of the product! But - they no longer need to know or care what the requirements of the product _are_. That knowledge becomes lost inside the TSO, whose state is difficult to review and has limited history tracking.

Does your team know which licenses, features, and settings your product requires? The TSO knows, but it cannot tell you - at least, not easily.

The discoverability issue

## TSO as Binary Blob

> Thesis: TSOs do not reflect the customer experience.

When you have a TSO, you have a statement about how your product is installed and used. But that statement is 

## Disaster Recovery

> Thesis: TSOs have no disaster recoverability.

TSOs suffer from the same problem as first-generation packaging orgs: they are long-lived orgs whose state _must_ be mutated during the development and delivery process, but whose state it is inherently dangerous to mutate. It's dangerous because if you make a mistake, you may not be able to put it back. And you might even put your org into an unrecoverable or difficult-to-recover state, imposing heavy costs on your business and blocking your ability to deliver to customers for an extended period of time.

Suppose this scenario, for example. Robin, a Massive Events quality engineer, is working on pre-release testing. She's been passed a managed beta release, Massive Events 1.29 Beta 3, by Anton, an engineer. Robin sits down to install the managed beta in her testing environment, but she doesn't realize she's still logged in to the production TSO from a previous task. She installs the managed beta in the TSO by mistake.

Managed beta packages cannot be upgraded - ever. When you install a managed beta in an org, that org's lifecycle ends there, unless you go through the effort to completely uninstall the package. And in a fully-customized TSO, that uninstallation is likely somewhere between very hard and impossible.

Robin's stuck. She made an honest mistake, but it's a mistake that will take days of work to undo at best. She'll have to tear the TSO's state down to bedrock, uninstall or delete every customization or data record that depends on Massive Events in any way, try to uninstall the managed beta, and then build the whole state back up again. And in the meantime, what if the company discovers a high-priority security flaw in Massive Events? They won't be able to issue a new TSO snapshot to provision new customers, so they'll have to take onboarding completely offline until the TSO is repaired. And even then, it'll have to go through extensive testing to make sure the state was restored to where it needed to be.

Robin's mistake is one of the more dramatic ways to break or damage a TSO, but it's far from the only one. Creating extra users; enabling Record Types on a new sObject; turning on Person Accounts: many changes have permanent or semi-permanent impacts, and those impacts can vary from a mild annoyance to a complete business stoppage. Because there's no capability to roll back a TSO's state, you're fundamentally without a disaster recovery (DR) strategy other than creating a new TSO. Ensuring that that creation is possible at a reasonable cost requires care and discipline. (Or, as we'll see below, a comprehensive source-driven strategy).


## Part 3: How TSOs Fail Your Customers

> Thesis: as the product evolves and grows, the lack of modularity implicit in the TSO strategy becomes a stronger and stronger blocker.

If you build out multiple TSOs, you will certainly encounter state drift. This results in, for example, QA or product demos not reflecting the state that is actually delivered to customers.

## TSO as Agility Blocker

TSOs can deliver only new orgs. There is no such thing as a modular TSO; you cannot layer a TSO on top of an existing org. That means that the effort cliff on _composability_ is a vertical line.

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

Suddenly your team, instead of updating _one_ org every release, is making the same changes in a dozen, or two dozen, orgs. There's essentially no way to share that work. You've just got to repeat it two dozen times. Humans make mistakes. Tight deadlines result in one-off changes in this org or that org. State drifts. The documentation does not match. You're spending tons of time that could be used to create customer value just updating all these cursed orgs. 

Before long, you no longer have any clarity about how the product is actually meant to be delivered.

---

> Thesis: TSOs prevent you from serving existing customers well.

Maybe your story doesn't quite match this one. You don't get acquired. You have a single product. You grow it slowly, and you stick with one TSO. But your agility is still hampered! 

You build out a new, incremental release. It adds a really slick new feature, but the feature needs to be enabled by customers. That work takes a while - a few days of work for a skilled administrator. Your docs team write excellent content to enable admins, and your staff use that documentation to update the TSO. Now, new customers will start with that feature fully enabled and ready to use. They can realize the value on day 1.

... but what about your existing customers? They've already got customized orgs. They cannot use the TSO to get your pre-built enablement for this new feature. Their admins are stuck doing those days of work based on your documentation.

That's a shame. Is it a product-breaker? Probably not. But it means that you cannot deliver that value through any channel other than a brand-new customer org signup.

## Part 4: How to Use TSOs Effectively

> Thesis: TSOs and Org Snapshots are effective operational tools, but they're not part of your product.

I've said a lot against TSOs. Let me say one thing for them: TSOs work well for their core purpose, which is generating a new org for a user or customer. The `SignupRequest` API is simple to use and the process is effective.

We can consume that core function of the TSO without sacrificing our SDLC goals - without incurring all of the problems discussed above. We do that by using a _source-driven TSO_ model.

The source-driven TSO model reflects best practices for developing against production Salesforce orgs throughout the ecosystem. _Don't develop in production!_ With the source-driven model, we externalize the TSO's source of truth into version-control-based metadata, data, and automation, much like how customers externalize their production source of truth into a repository. For TSOs, though, we go even further. We don't just store our application metadata in version control, but also data that we wish to represent in our trial configuration, and setup automation that brings our TSO to the state we desire.

Then, just like with a best-practices production org, we make a rule: no changes directly in production! Instead, you develop changes in an isolated environment, preferably a scratch org, that looks just like the TSO. (It looks just like the TSO because we use _the same automation_ to create it). We capture changes from that org and persist them in version control. Then, once we move that change through our SDLC, that automation is run against the production TSO to update its state. Finally, a new snapshot is created and shared with stakeholders to allow signup.

The source-driven TSO model might at first blush sound like quite a bit of extra work. And it's true, if we consider only the span between defining a change and making that change, on the one hand through automation and source control and on the other hand through direct changes in the production TSO.

If we expand the scope of our awareness across the product lifecycle and consider all of the challenges we discussed above, the cost/benefit analysis of the source-driven TSO model dramatically changes.

### Source of Truth and Visibility

### SDLC Best Practices and Compliance

### Disaster Recovery

### Composability
