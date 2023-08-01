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

- **Engineers** use TSO snapshots to spin up orgs that they use operationally, to execute development, explore product configuration or perform early-stage testing. In some cases, this can be a separate TSO that is specifically designed for internal or operational use cases, rather than the customer-facing TSO. 
- **Quality engineers** use TSO snapshots to test their product in a fully-configured environment, without paying the expense of environment setup every time.
- **Product managers** and **demo or sales engineers** use TSOs 
- **Partners** use TSO snapshots you share with them to jump-start their customer implementations, as well as to support internal learning and training use cases.
- **Customer delivery** is the core use case for TSOs. Customers are provisioned a new Salesforce org by cloning from a TSO snapshot. This results in the customer org starting from a fully-configured position.


## Part 1: How TSOs Fail Your Team

> Thesis: TSOs divide the source of truth for the product.

Modern development projects focus on version control as the _source of truth_. Your version control repository (usually, but not always, Git) is the canonical definition of what makes up your product, and it's the operational hub of your software development lifecycle (SDLC). Version control comes with a litany of benefits I won't evangelize in any detail here.

When you introduce a TSO into your product development, the source of truth becomes ambiguous. Here's a failure case.

The Massive Events team is building out a new feature.


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

Is using a TSO a genuine risk to an audit, given a clever enough auditor? I have no idea. Although I've answered a lot of questions from compliance auditors, I'm not an expert on the complexities of SOC2 and the like. Could you mitigate these risks with appropriate process enhancements? Yes, you could. But I think it's clear that TSO-based development _as it's often done_ - in-org, outside the context of a well-defined SDLC - absolutely violates the spirit of many audit goals. It's not trackable in version control. It is likely not reviewed and approved by a distinct member of the team. And there are limited tools (the Setup Audit Trail) to understand and evaluate changes made in the org. 

All of those core capabilities are built in to every version control system under the sun.

Whether or not these process shortfalls are actually of concern to auditors, they should absolutely be of concern to anyone who has an eye on the underlying goals of audit and compliance processes. 

---

> Thesis: TSOs inhibit teams from socializing critical knowledge about the product and how it works.

A corollary to the source-of-truth problem is _knowledge limitation_.

When your team works heavily with TSOs, the TSO itself _de facto_ becomes part, not just of your source of truth, but of your knowledge base about the product and how it works. Users can easily create orgs that match the requirements of the product! But - they no longer need to know or care what the requirements of the product _are_, or what the journey to set up the product looks like. That knowledge becomes lost inside the TSO, whose state is difficult to review and has limited history tracking.

Does your team know which licenses, features, and settings your product requires? Does your team know how to execute setup, from scratch, for a new customer? The TSO does. But it can't tell you.

The discoverability issue

---

> Thesis: TSOs do not reflect the customer experience.

When you have a TSO, you have a story about how your product is installed and used. That story is true, but it's very limited: it only reflects one path through which customers obtain and use your product. In a few cases, like OEMs, that path might be the only one. But for most ISVs, the story your TSO tells about product delivery and use omits a swathe of other true customers stories. When, for example,

- a Massive Events implementation partner starts a project from the TSO, but wipes out much of the delivered configuration and then builds their own;
- an implementation partner skips the TSO and prepares an implementation from scratch;
- a customer brings Massive Events into an existing, heavily customized org;
- a customer starts a fresh org with Massive Events, but it's a Professional Edition rather than Enterprise Edition;
- a learner installs Massive Events in their Trailhead Playground;

the story looks very different, and the org that results also looks very different.

This gap impacts users across the application lifecycle. Engineers miss risk because they're used to the TSO and don't know the heterogeneity of customer orgs. Quality engineers test in one version of the customer story, but don't see others, and bugs slip through. Product managers lose sight of the breadth of their customer base. And Support has to track down complex challenges that they don't have resources to address.

---

> Thesis: TSOs have no disaster recoverability.

TSOs suffer from the same problem as first-generation packaging orgs: they are long-lived orgs whose state _must_ be mutated during the development and delivery process, but whose state it is inherently dangerous to mutate. It's dangerous because if you make a mistake, you may not be able to put it back. And you might even put your org into an unrecoverable or difficult-to-recover state, imposing heavy costs on your business and blocking your ability to deliver to customers for an extended period of time.

Suppose this scenario, for example. Robin, a Massive Events quality engineer, is working on pre-release testing. She's been passed a managed beta release, Massive Events 1.29 Beta 3, by Anton, an engineer. Robin sits down to install the managed beta in her testing environment, but she doesn't realize she's still logged in to the production TSO from a previous task. She installs the managed beta in the TSO by mistake.

Managed beta packages cannot be upgraded - ever. When you install a managed beta in an org, that org's lifecycle ends there, unless you go through the effort to completely uninstall the package. And in a fully-customized TSO, that uninstallation is likely somewhere between very hard and impossible.

Robin's stuck. She made an honest mistake, but it's a mistake that will take days of work to undo at best. She'll have to tear the TSO's state down to bedrock, uninstall or delete every customization or data record that depends on Massive Events in any way, try to uninstall the managed beta, and then build the whole state back up again. And in the meantime, what if the company discovers a high-priority security flaw in Massive Events? They won't be able to issue a new TSO snapshot to provision new customers, so they'll have to take onboarding completely offline until the TSO is repaired. And even then, it'll have to go through extensive testing to make sure the state was restored to where it needed to be.

Robin's mistake is one of the more dramatic ways to break or damage a TSO, but it's far from the only one. Creating extra users; enabling Record Types on a new sObject; turning on Person Accounts: many changes have permanent or semi-permanent impacts, and those impacts can vary from a mild annoyance to a complete business stoppage. Because there's no capability to roll back a TSO's state, you're fundamentally without a disaster recovery (DR) strategy other than creating a new TSO. Ensuring that that creation is possible at a reasonable cost requires care and discipline. (Or, as we'll see below, a comprehensive source-driven strategy).

---

> Thesis: as the product evolves and grows, the lack of modularity implicit in the TSO strategy imposes greater and greater cost on your delivery strategy.

TSOs can deliver only new orgs. There is no such thing as a modular TSO; you cannot layer a TSO on top of an existing org. The consequences of this fact are not always obvious: "That's the point of a TSO," you might say. But as a product and customer base grows, the weaknesses of the TSO as a delivery strategy become more and more apparent. Let's look at some key points during the lifespan of the Massive Events product:

Massive Events starts small, with one managed package, and delivers to customers via a TSO. That's great - it keeps effort nice and low, and Massive Events can serve customers and internal stakeholders with the same TSO-based artifacts.

The product evolves. Soon, a Solution Engineering team comes on board, and they've got their own ideas about how to set up the product to support demos and sales most effectively. Massive Events spins up a new TSO to support demo orgs, configured just the way Solution Engineering likes it. The QA team, seeing an opportunity to dramatically reduce their manual setup time, starts using the new TSO as well. Before long, they're asking for their own TSO with a few variations on what Solution Engineering uses.

Meanwhile, Engineering keeps refining the product. They update the TSO each time they do a release to match the current known-good configuration of the product. But now, they have two, or maybe three, TSOs to update. Communication and ownership between Engineering and Solution Engineering start to become a challenge. Who owns the other TSOs? Who's responsible for defining the "right" configuration of each new product feature? And how are the internal shapes reconciled with what's delivered to customers?

Massive Events makes a big push and releases Version 2 of the product. It's now three managed packages working in concert. Many of the configurations Massive Events previously recommended are no longer preferred. The TSO (well, all of the TSOs) gets a top-to-bottom overhaul. But what can the company do to support existing customers? They don't receive the changes to the TSO, and must manually reconfigure their orgs to match the new setup.

The company's been acquired. That's great! New ownership doubles down on the product line. Now, Massive Events needs to integrate with a suite of five other products serving multiple verticals, with Events for Nonprofits, Education, Entertainment, and Sports. Each vertical demands a comprehensive configuration, with different packages and configuration. What does the team do about their delivery strategy?

- Should they build out five new TSOs, to represent the deliverable state of the product with each of those other applications?
- What about customers that fall in more than one vertical, like a higher education customer that also does sports events? That use case requires yet another configuration. It starts to look like quite a lot of TSOs.
- What about Solution Engineering and QA - will they still need their own, separate TSOs for demo configurations?

Suddenly the Massive Events team, instead of updating _one_ org every release, is making the same changes in half a dozen, or a dozen, orgs. There's essentially no way to share that work. They've just got to repeat it two dozen times. Humans make mistakes. Tight deadlines result in one-off changes in this org or that org. State drifts. The documentation does not match. Massive Events is spending tons of time that could be used to create customer value just updating all these cursed orgs. 

Before long, no member of the Massive Events team has clarity about how the product is actually meant to be delivered.

---

> Thesis: TSOs prevent you from serving existing customers well.

Maybe your story doesn't quite match this one. You don't get acquired. You have a single product. You grow it slowly, and you stick with one TSO. But your agility is still hampered! 

You build out a new, incremental release. It adds a really slick new feature, but the feature needs to be enabled by customers. That work takes a while - a few days of work for a skilled administrator. Your docs team write excellent content to enable admins, and your staff use that documentation to update the TSO. Now, new customers will start with that feature fully enabled and ready to use. They can realize the value on day 1.

... but what about your existing customers? Or your new customers who already own Salesforce orgs? They've already got customized orgs and don't need a new one matching your TSO. They cannot use the TSO to get your pre-built enablement for this new feature. Their admins are stuck doing those days of work based on your documentation.

That's a shame. Is it a product-breaker? Probably not. But it means that you cannot deliver that value through any channel other than a brand-new customer org signup.

## Part 2: How to Use TSOs Effectively

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
