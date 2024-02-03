+++
title="On the Problems with TSOs"
draft=true
+++

## Introduction to TSOs

One of the most common methods of distributing Salesforce orgs and packages is the _TSO_: a _Trialforce Source Org_.

At the simplest, a TSO is a Salesforce org that you can copy. You install a product, set up all of the configuration, add sample data, and perform whatever other customization you wish. Then, you take a _snapshot_ of that org (using the Setup->Trialforce UI). The snapshot captures the complete state of that org at a point in time. You can have many snapshots over the evolution of the TSO's state.

Once you have a snapshot, you can perform _signups_ against it. A signup creates a new, completely independent org that looks exactly like the original snapshot. The signup process can take several forms:

- You can use Environment Hub in your Partner Business Org (PBO).
- You can expose a snapshot in your AppExchange listing, allowing customers to sign up trials.
- You can call the `SignupRequest` API from your own automation, passing the `0TT` id of your snapshot. (For this use case, you have to file a Case to have your template Id blessed).

In any case, you get back authentication information for your new org. For Environment Hub and AppExchange signups, this means you get an email to set your user password; for API-based signups, your automation gets back an authentication code it can exchange for an OAuth refresh token. 

Where the _trial_ part of _Trialforce_ comes in is that that new org has a fixed lifespan, after which it has to be converted to a production org (or disposed). 30 days is a common trial length, but it's not universal.

This functionality might sound quite nice. And in some ways, it is! TSOs are very effective at delivering copies of whole Salesforce orgs, including configuration that is very time-consuming to set up from scratch. If it were all that straightforward, of course, this essay wouldn't be here. In fact, there are a number of patterns in how TSOs are used that have deep negative effects on the software development and delivery lifecycle. My purpose in this essay is to explore those negative effects and lay the groundwork for an alternate approach, in a second part to follow. Thoughout, I'll use an imaginary development team building a managed package-based product called Massive Events.

## The Source of Truth

> Challenge: TSOs divide the source of truth for the product and inhibit the team from socializing critical knowledge about its foundations.

Modern development projects focus on version control as the _source of truth_. Your version control repository (usually, but not always, Git) is the canonical definition of what makes up your product, and it's the operational hub of your software development lifecycle (SDLC). Version control comes with a litany of benefits I won't evangelize in any detail here.

When you introduce a TSO into your product development, the source of truth becomes ambiguous. Here's a failure case.

The Massive Events team is building out a new feature.

A corollary to the source-of-truth problem is _knowledge limitation_.

When your team works heavily with TSOs, the TSO itself _de facto_ becomes part, not just of your source of truth, but of your knowledge base about the product and how it works. Users can easily create orgs that match the requirements of the product! But - they no longer need to know or care what the requirements of the product _are_, or what the journey to set up the product looks like. That knowledge becomes lost inside the TSO, whose state is difficult to review and has limited history tracking.

Does your team know which licenses, features, and settings your product requires? Does your team know how to execute setup, from scratch, for a new customer? The TSO does. But it can't tell you.

If you only ever provision orgs via the TSO snapshots, that's fine: you don't need that knowledge! But that assumption's just not true for any real-world use case. If a customer comes in who has an existing org they want to activate your product in, are you going to tell them "Sorry, you have to provision a new org via our TSO?" (That's an OEM workflow, but it wouldn't be healthy for most ISVs!)

TODO: complete

## Change Management and Compliance

> Challenge: TSOs make change management and review very difficult. It's hard to practice TSO development within a compliance framework.

Compliance processes often focus heavily on version control. Git, combined with your system of record for tracking work, forms an audit log. It tells the story of how your product got to where it was: who made what change, why they made it, and who signed off to approve the change. TSOs make it difficult or impossible to answer those three questions. 

The Massive Events is going through their annual compliance audit. This year, they've engaged a new auditing firm, and the auditors haven't worked on Salesforce-based products before. They dig into the Massive Events release process, and think they understand how new customers are onboarded.

1. The development team releases a managed package version. The release is done by a release engineer, after signoff by a quality engineer. The release work is tracked in a ticketing system.
    a. The auditors nod, and make notes. They understand this paradigm.
1. The product manager logs into the TSO and installs the new package version. They update some Page Layouts and Profiles to reflect the new version, and walk through the user experience to make sure everything looks right. If there's an issue, they fix it along the way.
    a. "Where is this work tracked?" the auditor asks. "Who approves it?"
1. The product manager creates a new TSO snapshot and enables it for customer signup.
    a. The auditor starts to look concerned. "Isn't this the actual release? Who signs off on this artifact? How is it tested?"
1. The product manager has the only login to the TSO.
    a. The auditor looks _very_ concerned. "What if the product manager were a bad actor? They could deliver anything in the TSO, even malicious code."

Is using a TSO a genuine risk to an audit, given a clever enough auditor? I have no idea. Although I've answered a lot of questions from compliance auditors, I'm not an expert on the complexities of SOC2 and the like. Could you mitigate these risks with appropriate process enhancements? Yes, you could. But I think it's clear that TSO-based development _as it's often done_ - in-org, outside the context of a well-defined SDLC - absolutely violates the spirit of many audit goals. It's not trackable in version control. It is likely not reviewed and approved by a distinct member of the team. And there are limited tools (the Setup Audit Trail) to understand and evaluate changes made in the org. 

All of those core capabilities are built in to every version control system under the sun.

Whether or not these process shortfalls are actually of concern to auditors, they should absolutely be of concern to anyone who has an eye on the underlying goals of audit and compliance processes. 

## Customer Experience

> Challenge: TSOs reflect one facet of the customer experience and tend to blot out its breadth and heterogeneity.

When you have a TSO, you have a story about how your product is installed and used. That story is true, but it's very limited: it only reflects one path through which customers obtain and use your product. In a few cases, like OEMs, that path might be the only one. But for most ISVs, the story your TSO tells about product delivery and use omits a swathe of other true customers stories. When, for example,

- a Massive Events implementation partner starts a project from the TSO, but wipes out much of the delivered configuration and then builds their own;
- an implementation partner skips the TSO and prepares an implementation from scratch;
- a customer brings Massive Events into an existing, heavily customized org;
- a customer starts a fresh org with Massive Events, but it's a Professional Edition rather than Enterprise Edition;
- a learner installs Massive Events in their Trailhead Playground;

the story looks very different, and the org that results also looks very different.

This gap impacts users across the application lifecycle. Engineers miss risk because they're used to the TSO and don't know the heterogeneity of customer orgs. Quality engineers test in one version of the customer story, but don't see others, and bugs slip through. Product managers lose sight of the breadth of their customer base as they define new features. And Support has to track down complex challenges that they don't have resources to address.

## Rollback and Disaster Recovery

> Challenge: TSOs are a dangerous persistent state that cannot be rolled back or restored easily.

TSOs suffer from the same problem as first-generation packaging orgs: they are long-lived orgs whose state _must_ be mutated during the development and delivery process, but whose state it is inherently dangerous to mutate. It's dangerous because if you make a mistake, you may not be able to put it back. And you might even put your org into an unrecoverable or difficult-to-recover state, imposing heavy costs on your business and blocking your ability to deliver to customers for an extended period of time.

Suppose this scenario, for example. Robin, a Massive Events quality engineer, is working on pre-release testing. She's been passed a package version, Massive Events 1.29 Beta 3, by Anton, an engineer. Robin sits down to install the managed beta in her testing environment, but she doesn't realize she's still logged in to the production TSO from a previous task. She installs the managed beta in the TSO by mistake.

Managed beta packages cannot be upgraded - ever. When you install a managed beta in an org, that org's lifecycle ends there, unless you go through the effort to completely uninstall the package. And in a fully-customized TSO, that uninstallation is likely somewhere between very hard and impossible.

Robin's mistake is one of the more dramatic ways to break or damage a TSO, but it's far from the only one. Creating extra users; enabling Record Types on a new sObject; turning on Person Accounts: many changes have permanent or semi-permanent impacts, and those impacts can vary from a mild annoyance to a complete business stoppage. Because there's no capability to roll back a TSO's state, you're fundamentally without a disaster recovery (DR) strategy other than creating a new TSO, either from scratch or from a previous snapshot. Ensuring that that creation is possible at a reasonable cost requires care and discipline in how you take and store snapshots so that changes aren't lost and you know what the state actually is. (Or, as we'll see below, a comprehensive source-driven strategy).

Robin's mistake is one of the more dramatic ways to break or damage a TSO, but it's far from the only one. Creating extra users; enabling Record Types on a new sObject; turning on Person Accounts: many changes have permanent or semi-permanent impacts, and those impacts can vary from a mild annoyance to a complete business stoppage. Because there's no capability to roll back a TSO's state, you're fundamentally without a disaster recovery (DR) strategy other than creating a new TSO. Ensuring that that creation is possible at a reasonable cost requires care and discipline in how you take and store snapshots. (Or, as we'll see below, a comprehensive source-driven strategy).



TSOs also expire after a year unless you file a case to extend.

Snapshots have to be approved if used in the SignupRequest API.

## Modularity and Serving Product Growth

> Challenge: as the product evolves and grows, the lack of modularity implicit in the TSO strategy imposes greater and greater cost on your delivery strategy.

TSOs can deliver only new orgs. There is no such thing as a modular TSO; you cannot layer a TSO on top of an existing org. The consequences of this fact are not always obvious: "That's the point of a TSO," you might say. But as a product and customer base grows, the weaknesses of the TSO as a delivery strategy become more and more apparent. Let's look at some key points during the lifespan of the Massive Events product:

Massive Events starts small, with one managed package, and delivers to customers via a TSO. That's great - it keeps effort nice and low, and Massive Events can serve customers and internal stakeholders with the same TSO-based artifacts.

The product evolves. Soon, a Solution Engineering team comes on board, and they've got their own ideas about how to set up the product to support demos and sales most effectively. Massive Events spins up a new TSO to support demo orgs, configured just the way Solution Engineering likes it. The QA team, seeing an opportunity to dramatically reduce their manual setup time, starts using the new TSO as well. Before long, they're asking for their own TSO with a few variations on what Solution Engineering uses.

Meanwhile, Engineering keeps refining the product. They update the TSO each time they do a release to match the current known-good configuration of the product. But now, they have two, or maybe three, TSOs to update. Communication and ownership between Engineering and Solution Engineering start to become a challenge. Who owns the other TSOs? Who's responsible for defining the "right" configuration of each new product feature? And how are the internal shapes reconciled with what's delivered to customers?

Massive Events makes a big push and releases Version 2 of the product. It's now three managed packages working in concert. Many of the configurations Massive Events previously recommended are no longer preferred. The TSO gets (well, all of the TSOs get) a top-to-bottom overhaul. But what can the company do to support existing customers? They don't receive the changes to the TSO, and must manually reconfigure their orgs to match the new setup.

The company's been acquired. That's great! New ownership doubles down on the product line. Now, Massive Events needs to integrate with a suite of five other products serving multiple verticals, with Events for Nonprofits, Education, Entertainment, and Sports. Each vertical demands a comprehensive configuration, with different packages and configuration. What does the team do about their delivery strategy?

- Should they build out five new TSOs, to represent the deliverable state of the product with each of those other applications?
- What about customers that fall in more than one vertical, like a higher education customer that also does sports events? That use case requires yet another configuration. It starts to look like quite a lot of TSOs.
- What about Solution Engineering and QA - will they still need their own, separate TSOs for demo configurations?

Suddenly the Massive Events team, instead of updating _one_ org every release, is making the same changes in half a dozen, or a dozen, orgs. There's no way to share that work. They've just got to repeat it over and over again. Humans make mistakes. Tight deadlines result in one-off changes in this org or that org. Different stakeholders aren't aligned on the best approaches. State drifts. The documentation does not match. Massive Events is spending tons of time that could be used to create value updating all these orgs, and answering questions about all these orgs. Customer cases start to pile up with issues in this TSO or that TSO or their orgs that don't match the TSO or the documentation.

Soon enough, no member of the Massive Events team has clarity about how the product is actually meant to be delivered or used. 

---

There are other ways Massive Events' story could go. They don't get acquired. They have a single product. They grow it slowly, and they stick with one TSO - sorry, Solution Engineering! But their agility is still hampered.

Massive Events build out a new, incremental product release. It adds a really slick new feature using predictive analytics to forecast event attendance. The feature has many components in the package, and also needs setup on Page Layouts and other customer-owned (non-upgradeable) components. The setup work takes a while: a few days of work for a skilled administrator.

The docs team write excellent content to enable admins, and Massive Events teams use that documentation to update the TSO. Now, new customers will start with that feature fully enabled and ready to use. They can realize the value on day 1. That's the promise of TSO-based delivery!

Here's the problem, though: Massive Events has thousands of stakeholders - customers, partners, and internal users - who all want that enablement too. Those users have existing orgs. Some are customer business orgs; others are customized demo environments; still others are the orgs partners use to start implementations. A TSO only spawns new orgs. There's no way to graft those in-TSO changes for the new feature into these existing environments.

All of those stakeholders are stuck doing days or weeks of work based on the documentation.

That's a shame. Is it a product-breaker? Probably not. But it means that Massive Events cannot effectively deliver the new value they build through any channel other than a brand-new customer org signup. That raises costs for their customers and stakeholders, and it hampers customer adoption and value generation. 

## Conclusion

TSOs are great at what they do: delivering a new org that looks just like an org you've created. But they come with uncomfortable long-term costs, and limit the agility of an ISV. 

In part 2 of this series, I'll look at how to use TSOs (or "org artifacts" more broadly) in an effective way.

