+++
title="A Taxonomy of Orgs for ISVs"
draft=true
+++

Abstract
The lifecycles of SFDO products take place in a sometimes-bewildering variety of Salesforce orgs and across several different types of packages and deployments. This document is intended to introduce key distinctions between Salesforce orgs and package types. It’s designed to be accessible for non-developers and is intended to help you understand the development lifecycle of our products as it relates to other activities that are part of our overall process, including testing and QA, product management, and demonstrations.

Quick Definitions
An org is the basic environment of Salesforce’s cloud platform. When you log in to Salesforce, you are in an org. An org contains both data and metadata. Orgs come in many types, which we’ll discuss at length in the Orgs section below.

Metadata is the customization that makes your org your org. It includes Apex source code, custom objects, page layouts, Lightning components, Visualforce pages, settings, and many more entities. It may be packaged or unpackaged.

A package is a named container for metadata. You can think of a package as being roughly analogous to an app installed from an app store on macOS or Android or through a package manager on Linux, but keep in mind that these analogies are loose and much of what’s important about packaging is unique to Salesforce.

A product is what we deliver to customers. It may consist of one or more packages, as well as unpackaged metadata, setup automation, or other services.

Packages and Deployments
Like other Salesforce Independent Software Vendors (ISVs), we deliver our products to customers in the form of packages. A package is a container for all of the customizations (metadata) that makes up our product. When a customer receives one of our products, like NPSP, they receive the one or more packages that collectively make up that product, potentially also with more unpackaged customizations and other automated setup that we’ve defined to give our customers a complete, tailored experience.

The customer might obtain this product by signing up for a trial org, performing an installation through MetaDeploy into an existing Salesforce org, or by using package installation links. (We won’t go into the details of installation processes here). While some of SFDO’s products are free and open source and others are not, all products are delivered to customers in the form of packages.

Salesforce packages come in three primary flavors: managed, unmanaged, and unlocked. Packaging comes in a first generation and second generation of functionality. Unmanaged packages are always first-generation. Managed packages may be first- or second-generation. Unlocked packages are always second-generation.

Managed packages have multiple versions, and each version has a status: either beta or released. For example, in August 2019, we released NPSP version 3.160 to customers. This is a managed release; it was preceded in the development lifecycle by more than a dozen managed betas, such as NPSP 3.160 Beta 14. Managed betas are used internally for testing, but aren’t delivered to customers.

In this document, we’ll be talking exclusively about managed packages, which come with a variety of capabilities that are important to us as a Salesforce ISV. Some of the major capabilities of the managed package are:

Preventing customer modifications to many delivered metadata entities.
IP protection for code.
Ability to push upgrades, including changes to existing metadata (with some limitations) and new metadata, to customers.
The objective of this section is to understand the different varieties of managed packages, how they’re employed throughout the development process, and what limitations constrain us when working with them.

Managed Releases
A managed release is the final, golden artifact of a product. Managed releases may be installed in any type of org and are capable of receiving push upgrades. SFDO creates and delivers managed releases of our products every two weeks.

Creating a managed release is a commitment to the end users who receive that package. Once we create a managed release, portions of the metadata we include in that release becomes immutable — by delivering it to customers, we’re committing not to change it in the future, and the platform enforces that commitment. The ISVforce Guide discusses the specific behaviors. If you have questions about what metadata is locked by a managed release, please discuss your concerns with Release Engineering.

Managed Betas
Managed betas are created during the development process leading up to a managed release. Each managed beta version has the version number of the forthcoming managed release that will follow it, plus a beta number. For example, NPSP 3.160 Beta 12 is the twelfth Beta version created during the development of NPSP 3.160.

Managed betas come with extra freedom relative to managed releases, but also a major additional limitation. Managed betas don’t lock in components the way managed releases do, because they’re not intended to be deployed to customers. As a consequence, however, managed betas once installed cannot be upgraded. A managed beta must be completely uninstalled (deleting all of its associated data) before a newer version can be installed.

Because of this key limitation, it’s critical never to install a managed beta in a persistent org whose lifespan is expected to continue beyond that managed beta version. Managed betas cannot be installed in production orgs at all, and they must never be installed in an LDV (large data volume) org or a sandbox that cannot be promptly refreshed. Managed betas are most suitable for use in scratch orgs.

2GP Managed Betas
We build 2GP managed betas in parallel during the development process, creating a single beta version on every commit on every branch. These parallel packages allow us to create testing proxies for the final managed betas, before we perform any merges to persistent packaging orgs. This takes advantage of the flexibility of 2GP package versioning to give us capabilities to move testing left, including complex end-to-end testing processes that span multiple packages.

To learn more about the 2GP testing process, read Testing with Second-Generation Packaging and Find Bugs Earlier with Second-Generation Packaging.

Unmanaged Packages
An unmanaged package is a named container for metadata, but doesn’t provide any of the additional functionality that’s available only to managed packages. While cci uses unmanaged packages as an implementation tool, you should rarely or never need to interact with unmanaged packages.

Typically, when you hear the word “unmanaged” at SFDO, this refers to metadata that is outside the scope of a package, rather than to an unmanaged package.

Unlocked Packages
Unlocked Packages are second-generation packages that provide functionality intermediate between managed packages and unmanaged packages. Unlocked packages are upgradeable, but don't provide IP protection and allow end users to modify packaged components. SFDO does not currently ship unlocked packages to customers.

Releases in the Development Lifecycle
Beta and released managed packages are a gate point in our development lifecycle.

A managed package version, whether beta or released, can be thought of as a snapshot of the metadata present in a single persistent org that we maintain: the packaging org for that package. Metadata is deployed to the packaging org once it’s merged to master, and a beta release is automatically generated.

Managed releases are created manually by Release Engineering during the biweekly release process. Managed releases aren’t created until after all regression has passed, in order to avoid locking in component versions and dependencies that have not yet been validated.

Because each package has only one packaging org, and because that org’s state is shipped as part of our product, we don’t have the liberty to experiment with managed releases. We cannot create managed releases of any kind during feature development (prior to merging to master).

Deployments and Installations
We extend the words “managed” and “unmanaged” from packages to also describe the metadata that makes up the package, and to the deployment of that package to a Salesforce org.

Hence we can talk about managed metadata, which is installed as part of a managed package, or unmanaged (or unpackaged) metadata, which is not. Likewise, we can talk about managed deployments or installations, where we install a managed package, and unmanaged deployments, where we install unmanaged metadata.

Note that the words “deployment” and “installation” may be used interchangeably in some contexts. Strictly speaking, “deployment” would apply to unmanaged metadata, and “installation” to a package; however, both words are often generalized to refer to the entire process of placing a product (one or more packages and unmanaged metadata) in an org.

When we install the released or beta versions of the NPSP, for example, we may describe this as a managed installation. This means we're installing the managed packages that are available to our customers. Conversely, when we use a development org and perform an unmanaged installation, we're installing the metadata that makes up the NPSP in an unmanaged form, much as NPSP's developers do.

Many SFDO packages also include unpackaged metadata that is never part of the managed package and may be installed alongside both managed and unmanaged installations. This metadata lives in the unpackaged folder within each project's repository. Some of this metadata is delivered to customers, while other portions are purely for internal use; for details, consult each project's documentation.

Unpackaged metadata exists for a variety of reasons, including an intention to deliver the metadata to customers and allow them to own and modify it; inability to package specific components; and desire to deploy metadata only to specific orgs.

In a managed installation, the unpackaged metadata is installed alongside the managed package. Note that unpackaged metadata which is delivered to customers cannot be altered in a push upgrade, and may be altered or deleted by the customer at any time.

It’s important to note that “managed” status is an attribute of a specific installation or deployment of metadata, not of the metadata per se. Metadata that is managed when installed as part of the NPSP managed package may also be installed unmanaged as part of an unmanaged deployment to a development org.

Push Upgrades
Push upgrades are the mechanism by which new managed releases may be delivered by SFDO directly to our existing customer base. Only managed releases may be involved in the push upgrade process. When we create new managed release versions of the packages that make up our products, we deliver those versions via push upgrade, which seamlessly installs the new version into their orgs.

However, not all managed metadata can be push upgraded, and only the actual package content is delivered. Any unpackaged metadata we include with new product installations is not included in the push upgrade, even if it’s been upgraded or extended. As a result, changes to unpackaged metadata are never delivered to existing customers — only to new customers. Additionally, some changes to packaged components, such as Page Layouts, aren’t delivered via push upgrades. Extensive information about push upgrade semantics on a per-component basis is available in the ISVforce Guide.

Namespaces
A managed package has a namespace, which is the API name prefix applied to all components that are part of the package. The namespace is a permanent attribute of the package - it can't be changed - and it's globally unique. The namespace is what allows us to push metadata into a customer org while maintaining a clear boundary between “ours” and “theirs”, preventing clashes at installation time and clearly defining the scope of the package.

You can always tell whether or not a piece of metadata is managed in a specific org by looking at its API name in Setup. Managed metadata components have an API name that starts with the namespace followed by two underscores.

npsp__Allocation__c is managed as part of the package with the npsp namespace.
Allocation__c is a piece of unmanaged metadata.
MailingStreet is a standard component.
Namespaces in Orgs
Orgs themselves can be associated with namespaces in two specific cases, both of which we’ll explore more below. Packaging orgs own the namespace for their associated package, and are capable of applying that namespace to metadata that is deployed into the org. Namespaced scratch orgs are a special type of scratch org with an inherent namespace, designed for use while building managed packages.

Orgs
Salesforce is a multitenant cloud platform. As a team building products on the Salesforce platform, we work with, and our products run inside, Salesforce orgs. An org is a single Salesforce environment, and an org can contain managed metadata from one or several packages, unmanaged metadata (including unpackaged metadata we deliver and end-user customizations), and, of course, data.

Orgs come in many different types. You’ll likely use more than one type of org in your work, and you’ll hear about others, both within SFDO and in customer contexts. We’ll start with a summary of the different org types you’re likely to encounter, and through the rest of this document we’ll focus on specific types that play major roles in our development, testing, and release processes.

Persistent Orgs and Scratch Orgs
The first key distinction is the lifecycle of the org, regardless of the additional features or configuration it may have. An org may be either a persistent org or a scratch org.

A scratch org is a disposable, temporary org with a fixed lifespan of 30 days or fewer. Because scratch orgs can be created and destroyed easily and come in many different types, we can use them to represent a wide variety of orgs into which our packages are likely to be installed. This makes scratch orgs a central tool in both the development and testing of our products.

Scratch orgs are created and manipulated through cci, through the MetaCI web interface, and through sfdx.

Note: SFDO has a large, but not infinite, allocation of scratch orgs. Please do not create and destroy scratch orgs at high volume without discussion with Release Engineering.

Persistent orgs, unlike scratch orgs, usually don’t have a fixed lifespan (other than those in a trial status). They are not disposable and cannot be reset to a blank slate. As a result, managing the lifecycle of persistent orgs is significantly more involved than is the case with scratch orgs. The use of persistent orgs at SFDO is limited: scratch orgs subsume the vast majority of our org use during the development and testing processes.

The orgs used by Salesforce customers are persistent orgs, as are sandboxes, Developer Edition orgs, and Trialforce source orgs.

Org Types and Shapes
We sometimes talk about orgs in terms of type or shape: the shape of an org is the combination of all of the parameters that go into making that org look and behave in a particular way. Both of these terms can be a little fuzzy, because there’s a great deal that goes into making an org. That might include the basic category of the org (such as production, sandbox, scratch, TSO, and so on), Salesforce edition of the org, limits on the org, the enabled feature set, like Communities, Person Accounts, or Multicurrency, any extra licenses provisioned, and configuration performed in Setup.

The factors that go into defining an org’s shape are myriad, and it can be very challenging to define an org shape fully. We’ll dig into orgs by first defining some of the key top-level categories. Then, we’ll dig into scratch orgs and look at the way we define scratch orgs to suit specific workflows. We’ll reserve the fine technical details of defining org shape outside the scope of this document; consult Release Engineering if you have more specific questions.

Production and Non-Production Environments
Orgs live on either a production Salesforce environment, like NA46 or CS111, or an internal environment, like STEAM or MIST.

Working with orgs on internal environments comes with special challenges. Packages aren't replicated from the production Salesforce environment to internal salesforce environments. This means that all of the packages built by Salesforce.org cannot be installed on orgs that live on non-production environments without manual intervention to migrate the package itself.

To learn more about working with non-production environments, read these documents:

CumulusCI for Persistent Orgs on Non-Production Environments
Exported SFDO Package Versions for Local and STEAM Builds
Production Orgs

Production orgs are special. A production org, at least nominally, is a real customer environment with a long-term lifespan, whose state must be carefully managed and protected against damage. Some changes made to an org’s state are irreversible or are very difficult to reverse.

One of the key consequences when we’re working with production orgs follows from this status: we can only install or deliver managed releases of our products, not managed betas. Managed betas cannot be upgraded, and installing them can be seen as applying an irreversible (or difficult and costly to reverse) modification to the org.

We can create persistent orgs that replicate a customer environment through Environment Hub in WLMA. Customers may be using any edition of Salesforce as their production org. You might hear these orgs referred to solely by their edition (“Enterprise Edition”, “Performance Edition”, and so on).

Production orgs are, and should be, used rarely in development and testing processes because they are heavy, long-lived environments. Whenever possible, use a scratch org, and select the release or beta shape (see below) to represent a customer environment.

Sandboxes
A sandbox is an org that is associated with a production org and can be refreshed from that org. Refreshing a sandbox completely replaces its customizations with a snapshot of the associated production org, and may also copy some or all of the data from Production. See Trailhead for more information about sandboxes.

Sandboxes, other than the special case of LDV (large data volume) orgs, don’t play a role in the SFDO development process, but they are used by customers extensively. We push our releases to customer sandbox orgs every 2 weeks. It’s possible to install a managed beta in a sandbox, but doing so requires a sandbox refresh before any further updates can be made. See above for more details.

Developer Edition Orgs
Developer Edition orgs are production orgs that are designed for development use. They replicate a customer environment in many respects, but come with significantly lower limits, including licenses, storage space, and other allocations. Developer Editions are used as long-lived environments by developers, but for most day-to-day processes, scratch orgs should be used instead.

Packaging Orgs
Packaging orgs are special Developer Edition orgs that are designated as the golden-master environment for a managed package. In most cases, you will not have access to a packaging org, but you may hear them discussed during the release process.

LDV (Large Data Volume) Orgs
LDV orgs are special sandboxes provisioned by ISV & Partner Support. These orgs come with approximately 100GB of data storage, allowing us to perform testing of our products pertinent to customers who have large data volume.

LDV orgs are a scarce resource and must be managed carefully. These orgs are persistent and cannot be reset or refreshed, like a scratch org or normal sandbox. Beta managed packages must never be installed in an LDV org. Changing the org’s installed packages and data set may be done only after consultation with the other teams using that LDV org and with Release Engineering, and access to these orgs must be serialized across projects to prevent collisions or mutually incompatible state changes. Resetting these orgs’ data state is time-consuming and should not be done frequently because it impacts the pod on which they are hosted.

SFDO currently owns two LDV orgs, one of which contains approximately 30GB of data and an unmanaged installation of NPSP (see below for more on installation types), and the other of which contains approximately 100GB of data, a managed installation of NPSP, and DSO.

Trialforce Source Orgs
Trialforce Source Orgs (TSOs) are specialized production orgs which are capable of serving as the source for customer trial sign-ups. A TSO contains managed releases of our packages, as well as additional customizations and optionally data. Typically, each product (not each package) would have one TSO or none.

Trialforce Templates are created from TSOs. Trialforce Templates represent a snapshot of the state of the TSO at a point in time, which is replicated to new customer environments created through trial sign-ups.

Scratch Orgs
Scratch orgs are used through the development lifecycle, from writing code to QA, regression testing, and further. Scratch orgs suit a wide variety of purposes because they may be spun up quickly and easily, and specced to have a wide variety of org shapes representing different development, testing, and customer-like configurations.

Here, we’ll tackle the breadth of scratch org usage by laying out some core facets of scratch org shape that are under the control of the user. Then, we’ll take a look at specific workflows within the development lifecycle and discuss how scratch orgs are built and used in each case.

Scratch Org Types
Scratch orgs are empty, out-of-the-box, disposable Salesforce environments. Their ultimate shape — what they look like when you open them and interact with them — is controlled by a blizzard of configuration options at many different levels:

The .json file within the project’s repository that defines a specific org shape.
The options in cumulusci.yml applied to the org shape, which include the org lifespan and namespace status.
Overrides specified in MetaCI, if the org is built there.
The packages, unpackaged metadata, and settings deployed by the CCI flow that is run against the org
And in some specific cases, even the Salesforce pod (such as NA112 or CS46) on which the org is created.
As a user, you don’t need to worry about most of those configuration options — they’re pre-designed and customized for each project. Instead, you can think about your orgs based on a few key distinctions that contribute to your selection of the org for a specific purpose. The underlying detail is abstracted away by our tools, CumulusCI and MetaCI.

Org Lifespan
All scratch orgs have a lifespan between 1 and 30 days, after which they're deleted. Orgs are typically configured to live between 1 and 7 days.

While it’s tempting to try to extend scratch org lifespans as long as possible, Release Engineering urges against it. Long-lived scratch orgs are a temptation towards usage patterns that can be problematic, like attempting to maintain an org and update it rather than generating a new one. Additionally, long-lived scratch orgs tend to lead to high scratch org limit consumption.

Why are persistent orgs and long-lived scratch orgs a problem?

To sum up succinctly, it’s due to “drift” in the configuration of the org — changes made through use that aren’t tracked, and which may have other side effects. Once the org no longer matches the output of a CCI Flow, results obtained in that org aren’t reproducible, often leading to red herrings in our processes. The best process to maintain reliable and reproducible testing is to always use clean scratch orgs.

If you have questions or concerns about org lifespan, or have a use case that does not work well with ephemeral orgs and could benefit from stronger build automation, please speak with your release engineer.

Installation Type
Earlier, we looked briefly at the distinction between a managed and unmanaged installation. The choice between the two, and their variants, is another key facet in defining the final shape of a scratch org: in what form do we want this package installed? Choices include:

Unmanaged: the raw, unpackaged metadata. This installation type is appropriate for development and for feature QA. Note that an unmanaged deployment isn’t the same as an unmanaged package, although CCI does use an unmanaged package as an internal tracking tool.
Beta: the most recent managed beta release. This installation type is appropriate for QA after features are merged to master, and for pre-release regression testing.
Managed (or prod): the most recent managed release. This installation type replicates a customer org, and may be appropriate for QA, investigations, demos, and other purposes.
Regression: this installation type models an upgrade. It first performs a managed (prod) install, and then a beta install. This pathway aims to replicate the shape of a customer org on the most recent release receiving an upgrade to the currently in-development version of the package.
Namespace
A namespace is a permanent attribute of a managed package. However, a scratch org can have a namespace too, a feature that can be useful in doing package development and sometimes during QA. When a scratch org is namespaced, it means that all metadata that's deployed to the org receives that namespace. In such orgs, there is no “boundary” between managed and unmanaged metadata — everything in the org receives the namespace, including unpackaged metadata that in a real customer installation will not have the namespace.

Namespaced scratch orgs are a necessary tool for building some older packages that use explicit references to their own namespaces, making it impossible to build them in un-namespaced orgs. They can also be useful for finding bugs in package code that manifests only in the presence of a namespace.

However, namespaced orgs can also be deceptive or allow bugs to slip through, because the critical package boundary (between managed and unmanaged metadata), present in a real customer installation, does not exist in a namespaced scratch org.

Namespaced scratch orgs are applicable only to unmanaged installations. It’s not possible to perform a beta, managed, or regression installation into a namespaced scratch org on the same project, and it’s rarely useful to do so on a namespaced scratch org on a different project.

Prerelease Status
During the run-up to each thrice-yearly Salesforce platform release, Release Engineering will enable prerelease builds and orgs for each project. A prerelease org is created on a special pod, CS46, that is upgraded to the new release of Salesforce very early in the process.

We run prerelease builds automatically at the feature level (before changes are merged to master) and at the beta release level. These builds are diagnostics to help us understand the impact of changes in each Salesforce release on our products.

Prerelease orgs can also be created manually for hands-on regression and other purposes. Watch for advice from Release Engineering when the prerelease window starts, and consult your project’s documentation for details. In most projects, a prerelease org may be created using the scratch org type prerelease and can have a qa_org or dev_org flow run against it, or the install_beta flow may be run against a scratch org of type beta_prerelease.

Selecting and Building an Org
Let’s look at how all of this background boils down in the form of choices you make as you create an org for your workflow. You’ll be using either cci in your terminal or MetaCI through your web browser to build orgs. The facets we’ve discussed so far are represented at different levels of detail in these two contexts, but the underlying mechanics and your decision points are the same. We’ll start by looking at CCI, and then turn to MetaCI’s web interface.

Org Types and Flows
There are are two choices you’ll make in CCI to get the right org for your needs: the org type and the flow you use to build it.

CCI provides, in every project, a list of named scratch orgs. The name identifies the starting point of the org’s configuration, encapsulating several of the top-level headings we discussed above, like Salesforce edition, namespaced status, prerelease status, and the Salesforce feature set that’s available in the org. Here's an abbreviated example from the NPSP project.

org                  default  scratch  days    expired  config_name          username
-------------------  -------  -------  ------  -------  -------------------  -----------------------------
dev                           *        7                dev
dev_namespaced                *        7                dev_namespaced       
feature                       *        6                feature              
prerelease                    *        1                prerelease
qa                            *        7                dev
release                       *        1                release
You may have created additional org names that you can use by giving the cci org scratch command. If you’ve created your own org names, look at the config_name column to see which configuration belongs to that org name.

In most cases, the config name will tell you what kind of org you're working with. You can usually assume that an org is namespaced or prereleased only if it's explicitly marked as such. In the list above,

dev_namespaced is an org with a namespace with a feature set suitable for development
dev does not have a namespace, and is likewise configured for development
qa is another name for a dev org (see the config_name) and is also non-namespaced.
prerelease is a prerelease org intended for development.
We say “usually” because these identities are defined on a project-by-project basis, and there are some projects that exclusively use namespaced orgs. If you have questions about which org types are namespaced on any given project, speak with Release Engineering or one of the developers.

Tasks and flows do not override the settings that are provided by the org configuration. Rather, when you specify an org to run your flow against, CCI builds the org based on the configuration assigned to that org name (as shown in cci org list, above). Flows and tasks may expect to be run against specific types of orgs — they might expect a namespace, for example. The flow itself does not create the aspects of configuration that are defined in the org’s named configuration. For example, if you run a flow that expects a namespaced org against a non-namespaced org, the org won’t become namespaced. While the exact behavior will depend on the situation, you’ll likely receive an error message if you attempt such a mismatch.

Let's look at an example. If you build a QA org for Cumulus using the qa_org flow, you might issue a command like this:

cci flow run qa_org --org qa
(If you've set a default org, you may not need to use the --org argument).

Looking at the table above, we see that qa is the name for an org using the dev scratch org definition, so we know it is not namespaced. Referencing the project’s documentation, we'd find that qa_org performs an unmanaged deployment, and that it also includes extra unpackaged metadata that’s designed to support QA processes. That combination of flow selection and org type yields the complete org shape that you need for your workflow.

MetaCI
In MetaCI, the two choices you have available (org type and flow) are condensed to one: the plan. The plan you choose in MetaCI’s “Create Org” user interface encapsulates the org type and the flow run to build the org.

MetaCI’s plans are named descriptively, and in line with the intended use case for the org. For example, you might choose to create a Dev Org or QA Org in MetaCI, for either of those specific purposes.

Note that not all of the choices that are available through CCI are represented in MetaCI plans. If what you need is not available in MetaCI and you wish to use that interface, please speak with your release engineer.

Mapping Orgs to Workflows
Consult your project’s automation documentation for specifics of which flow and org type to use for each workflow. This section shows conventional patterns, but individual projects may depart from these conventions based on their specific needs.
Development
Development orgs may or may not be namespaced, but are always built using an unmanaged deployment. It’s not possible to do development on a package that is installed in managed form.

Development orgs are typically built using the dev_org and dev_org_namespaced flows with org types dev and dev_namespaced. These orgs are not reflective of customer configurations.

Feature Testing (QA)
Feature testing QA orgs may or may not be namespaced, but are always built using an unmanaged deployment. This testing is done prior to merging metadata into master.

Development orgs are typically built using the qa_org and qa_org_namespaced flows with org types qa and qa_namespaced (if available) or dev and dev_namespaced.

QA orgs are typically identical to development orgs at the level of the org configuration. They differ by adding further unpackaged metadata designed to facilitate the testing process. These orgs are not reflective of customer configurations.

Beta Testing (QA)
Beta testing orgs are never namespaced and are built using a beta install type. This testing is done after merging metadata into master and before the final release process.

Beta orgs are typically built using the install_beta flow with the org type beta. Beta orgs usually do not include additional unpackaged metadata to support the testing process. These orgs are similar to customer orgs, but may not include all of the unpackaged configuration that is delivered to customers.

Regression Testing
Regression testing orgs are never namespaced and are built using a regression-style deployment. This testing is done after merging metadata into master and before the final release process.

Regression orgs are typically built using the regression_org flow with the org type release. Regression orgs may or may not include additional unpackaged metadata to support the testing process. These orgs are similar to customer orgs, but may not include all of the unpackaged configuration that is delivered to customers. They may include some additional metadata to support the testing process.

Trial
Products that are delivered to customers with complex configuration outside the package itself often define a Trial org. This org is intended to replicate the org configuration received by the customer when they initiate a new trial signup. The trial org may itself be a snapshot from the product’s TSO, or may be built via a CCI flow to achieve the same resulting org shape.

A trial org is typically built by running the trial_org flow against the org type release (if built using a flow), or simply by creating an org of type trial (if using a TSO snapshot). Consult your product’s automation documentation for details.

