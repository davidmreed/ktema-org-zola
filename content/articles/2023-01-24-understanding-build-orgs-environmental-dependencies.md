+++
title="Understanding Build Orgs, Part 1: Build Orgs and Environmental Dependencies"
draft=true
+++

> This series discusses second-generation managed and unlocked packages. It does not apply to org-dependent unlocked packages or to managed packages built with the Skip Validation option. Portions of this discussion also apply to first-generation managed packages, but different techniques apply in that context.

Creating a second-generation package version seems almost magical: there's no packaging org! No madness of org state to manage, deployments to run, components to check! Source just flows from your Git repository into a deliverable artifact.

... well, sort of. There's actually an org in there, but you can't see it or interact with it. It's a special scratch org called a _build org_. In a sense, it's a disposable packaging org. When you create a package version, your source is deployed to your build org, and your package artifact is uploaded from there. Then, the build org is disposed by the platform. No fuss, no muss.

Build orgs aren't something that you usually consider when you're building a product. You don't use them operationally, and they aren't part of delivering your product to customers. The first symptom you'll see of needing to consider them is when you go to upload a package version and get back errors that seem inexplicable:

```
Invalid type: ContentNote
DML requires SObject or SObject list type: ContentNote
AuraEnabled methods do not support parameter type of ContentNote
```

If you're seeing these errors and thinking "This metadata works just fine in all of my testing orgs", it's time to look at your build org. To understand why, we need to talk about _dependencies_.

Dependencies between packages are a well-understood part of the process, for both 1GP and 2GP packages. For second-generation packages, you list these dependencies in your `sfdx-project.json` (when using SFDX) or `cumulusci.yml` (when using CumulusCI). A dependency boils down to the requirement that, when Package B depends on Package A, you must install Package A before Package B. That ensures that _references_ in Package B to metadata that is owned by Package A can be satisfied at install time.

For example, Package A might expose an `@NamespaceAccessible` Apex class, `CommonUtils`. In Package B's own Apex it consumes that class:

```java
private class AccountService {
	public void processChildAccounts(List<Account> accounts) {
		if (CommonUtils.shouldProcessChildAccounts(accounts)) {
			// Execute some business logic.
		}
	}
}
```
If you should try to install Package B, or deploy Package B's source metadata, in an org without Package A, that reference to the `CommonUtils` class will not be satisfied and the package installation will fail. Its metadata is not valid in the context of the target org. In fact, you might see a message that resembles the example above about `ContentNote`.

Package-to-package dependencies are usually quite well-defined and understandable, because they're explicit and they're done by engineers on purpose. What we saw in the example failure above, which we said we needed to understand through the lens of a build org, is actually the same problem -- but it's harder to see, predict, and reason about. It's an _environmental_ dependency: a relationship between the functionality of the package and the configuration of the org itself (rather than another package). The `ContentNote` sObject exists only when the Enhanced Notes feature is turned on in the org, and it is _not_ turned on by default in the build org.

Packages can be more or less sensitive to the configuration of the org in which they're installed. You might think that a package has no such sensitivities, but you'd almost certainly be wrong. Even features commonly taken for granted (like Enhanced Notes, above, or Chatter) are in fact optional. When you scale your package to a customer base of any size, you'll rapidly find out where your assumptions about what a "normal" org looks like clash with the extraordinary variety of real-world orgs. I’ve even seen situations (although I believe they’ve mercifully been resolved) where a feature is on in all newly-created orgs, but may be off in existing customer orgs!

These environmental sensitivities come in uncountable forms. Many are related to features in the org, like the example above. Those feature sensitivities can also manifest as edition sensitivities, since Developer Edition, Enterprise Edition, and Partner edition scratch orgs have different default features enabled. Others are related to schema, like dependencies on Record Types or non-Public Sharing Models being enabled for a specific sObject. Others are even more complicated, particularly as you venture into extending licensed products.

## Defining and Satisfying Environmental Dependencies

As noted earlier, there's no way to directly access the build org. You can't log in to configure it, and even if you could, it'd be an anti-pattern -- you don't want to bring manual steps into your release processes! 

There are a dizzying array of factors that go into determining the shape of the org, and hence the elements upon which your package might find an environmental dependency. The edition, release, language, features, settings, and org settings all contribute to the final org shape. However, the platform gives you four primary tools to configure the build org as part of the scratch org definition file. Those are `features`, `settings`, `orgSettings`, and `sourceOrg`/`/snapshot`.

> These tools are also used for building plain old scratch orgs! Here, we'll focus on how they apply to satisfying package dependency scenarios.

### Features

Broadly, scratch org features represent configuration that you cannot turn on in Salesforce Setup without purchasing a license. 

That doesn't mean that your scratch orgs start empty of licenses and you add features for everything you wish to use. On the contrary, every scratch org has a certain set of licenses and features turned on right out of the factory, as part of its edition template (Enterprise, Developer, and so forth). Features allow you to add to this set.

There's a key question implicit in this discussion: what features are actually enabled out-of-the-box in Enterprise, Developer, and other editions? It's undocumented, and is not guaranteed to be consistent between releases or between prerelease and release-status scratch orgs. In fact, I've seen multiple situations where the same org edition has different features enabled between some release A, the prerelease for release B, and the production release B!

That leaves you in a position where you have to apply your knowledge of the platform, the intent you bring to your own development, and your experience building packages in many different types of org to suss out the minimum set of features your build orgs need.

Feature dependencies can manifest in many different ways. Here's one example, of a dependency on the `Communities` feature.

### Configuration Dependencies: Settings

Settings entities loosely map to configuration you perform in on pages within Salesforce Setup: not your customizations, but the way you configure built-in Salesforce features. There are _many_ [`Settings` entities](https://developer.salesforce.com/docs/atlas.en-us.242.0.api_meta.meta/api_meta/meta_settings.htm) supported by the Metadata API.

Settings are configured under the [`settings` key](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_scratch_orgs_settings.htm) in the scratch org definition file. All Metadata API-enabled settings are supported, _even if they are not explicitly documented in the SFDX Developer Guide_. The Metadata API documentation includes all of the available settings, which are represented in the JSON org definition file via a transformation into lower-camel-case.

One of the frustrating aspects of managing environmental dependencies is that there's no straightforward way to determine which settings are required for any given set of metadata or package. Even in the simple case where some setting exposes some sObject, a well-defined mapping does not exist. There's both an element of informed experimentation and of knowledge won from experience in deriving the right, and minimal, settings configuration your package needs.

Creating a configuration dependency can be very easy. Here's an example in Apex:

```java
public with sharing class ContentNoteAccess {
    public static void accessContentNotes() {
        System.debug(
            [
                SELECT Id
                FROM ContentNote
                LIMIT 1
            ]
        );
    }
}
```

The outcome, if we try to build a package with our basic build org configuration:

```
$ sfdx force:package:create -n Content-Notes -t Unlocked -r content-notes
$ sfdx force:package:version:create -d content-notes -x -f config/basic-org.json -w 100

ERROR running force:package:version:create:  ContentNoteAccess: Invalid type: Schema.ContentNote
```

The `ContentNote` sObject doesn't exist at all unless the Enhanced Notes feature is turned on, which is not the case in this build org.

It's not just Apex that can create these dependencies. We see a different manifestation of the same underlying problem via this customization-based example, a Page Layout referencing Quick Actions that are exposed only when Chatter is turned on.

Adding
```json
    "enhancedNotesSettings": {
      "enableEnhancedNotes": true
    }
```

to the `settings` section of our build org definition results in a successful outcome:

```
sfdx force:package:version:create -d content-notes -x -f config/with-content-notes.json -w 100
Successfully created the package version [08c1R000000XZxEQAW]. Subscriber Package Version Id: 04t1R000000kZKlQAM
Package Installation URL: https://login.salesforce.com/packaging/installPackage.apexp?p0=04t1R000000kZKlQAM
As an alternative, you can use the "sfdx force:package:install" command.
```
> Check out the complete example in the `content-notes` subdirectory in the [repo](https://github.com/davidmreed/Build-Org-Examples/).

### Schema Dependencies: Record Types and Sharing Models

Another very common environmental dependency is on schema configuration. 

Apex code (and rarely other metadata) can reference the `RecordTypeId` field on an sObject, whether standard or custom. Even if the package includes Record Types on that object, the reference establishes a dependency on the Record Type feature _at install time_. That means that there must be at least one Record Type on that sObject _before_ the package is installed. Here's a trivial example of Apex code that creates this type of dependency on the `Account` object:

```java
public with sharing class RecordTypeAccess {
    public static void accessAccountRecordTypes() {
        System.debug(
            [
                SELECT RecordTypeId
                FROM Account
                LIMIT 1
            ]
        );
    }
}
```

Any static reference of this kind creates the dependency on the Record Type feature.

Likewise, Apex code can establish an install-time dependency on a non-Public Sharing Model for an sObject. Such a dependency requires that the Sharing Model for that sObject be set to (for example) `Private` before the package is installed. The sObject may be standard or custom, but can't be part of the package itself.

These dependencies are satisfied via the confusingly-named `orgSettings` key in the scratch org definition file. This key allows you to specify default Record Types and Sharing Models in the build org. (We'll see exactly how this works under the hood in Part 2).

If we start by building our package, containing the example above, with a non-suitable build org definition:

```
$ sfdx force:package:create -n Record-Types -t Unlocked -r record-types
$ sfdx force:package:version:create -d record-types -x -f config/basic-org.json -w 100
```

We'll get back an error like this:

```
ERROR running force:package:version:create:  RecordTypeAccess: SELECT RecordTypeId
                       ^
ERROR at Row:2:Column:24
No such column 'RecordTypeId' on entity 'Account'. If you are attempting to use a custom field, be sure to append the '__c' after the custom field name. Please reference your WSDL or the describe call for the appropriate names.
```

As with most deployment errors, this message highlights a symptom (a field that your metadata references isn't available), but doesn't provide indicators of _why_ it is not present or how to address it. Experience, and internalizing patterns like those we're reviewing here, gives you the tools to interpret this error message as indicating a feature dependency on Account Record Types.

By modifying the build org definition to include

```json
  "objectSettings": {
    "account": {
      "defaultRecordType": "default"
    }
  }
```

we obtain a successful outcome:

```
$ sfdx force:package:version:create -d record-types -x -f config/with-account-record-types.json -w 100

Successfully created the package version [08c5f000000PCZyAAO]. Subscriber Package Version Id: 04t5f000000Jn2AAAS
Package Installation URL: https://login.salesforce.com/packaging/installPackage.apexp?p0=04t5f000000Jn2AAAS
As an alternative, you can use the "sfdx force:package:install" command.
```

> Check out the complete example in the `record-types` subdirectory in the [repo](https://github.com/davidmreed/Build-Org-Examples/).

### Solving Very Thorny Problems with Org Shapes and Org Snapshots

The [Org Shape](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_shape_intro.htm) feature allows you to create a scratch org whos basic shape (features, settings, edition, limits, and licenses) matches a production org. While this capability is more likely to be useful for end users building packages to install in their production orgs, it can also be used by ISVs to support building managed packages with org-shape dependencies that are difficult or impossible to reproduce using other tools, such as licenses and limit increases that aren't exposed using the scratch org feature framework.

An Org Snapshot goes even beyond Org Shape to include all of the customization in the org -- not just the basic shape elements like features and settings. Only Org Snapshots can address a handful of particularly thorny problems, like the one discussed below with required Record Types on sObjects owned by dependency packages. (Record Types aren't part of the Org Shape).

Org Shapes and Org Snapshots can help address environmental dependencies that are otherwise impossible to satisfy, making it possible to build 2GPs that couldn't exist without them. But both strategies also increase the extent to which the package pipeline depends on opaque artifacts -- the shape or snapshot -- which cannot be reviewed, diffed, or even inspected in source control. That facet exacerbates the difficulty of fully defining a package's dependencies, and for that reason I encourage using them for managed packaging only to solve specific problems.

---

There are a handful of environmental dependencies that are difficult or impossible to satisfy with a typical scratch org definition file. Licenses that aren't available in the feature framework, or configuration that isn't exposed to the Metadata API, can sometimes be addressed with Org Shape.

Deploy-time dependencies in packaged metadata on configuration other than features, org settings, or sObject Record Types or Sharing Models, cannot be addressed other than by using an org snapshot. One way to create such a dependency is to package a Business Process/Record Type on a standard object that includes references to custom picklist values. Since `StandardValueSet` cannot be packaged, there's no way to satisfy that reference without using an org snapshot as the basis of the build org -- and as of this writing, Org Snapshots are not GA!

Another complex challenge is a package that has a dependency on the Record Type feature for an sObject that's owned by one of its package dependencies. As we'll see in Part 2, this challenge actually illuminates some of the interior functioning of the build org creation process, but comes with other quirks too.

## Using Build Orgs

Creating a build org definition is the hard part. Actually putting it into use is comparatively a piece of cake!

### With `sfdx`

When you [create a package version](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_unlocked_pkg_create_pkg_ver.htm) with the SFDX CLI, you run a command like this:

```bash
$ sfdx force:package:version:create --definitionfile my-org.json ...
```

(You can also set `definitionFile` in your package's entry in `sfdx-project.json` so that you don't have to remember which definition file you meant to use).

### With CumulusCI

CumulusCI users [upload a 2GP version](https://cumulusci.readthedocs.io/en/stable/managed-2gp.html) like this:

```bash
$ cci flow run release_2gp_beta --org dev
```

CumulusCI automatically uses the scratch org definition file for the org `dev` (or whichever org you specify) as the build org definition. It also uses that org to look up the package version Ids for any 1GP packages that the 2GP package depends upon.

### Next Steps

In Part 2 of this series, we'll examine how build orgs work under the hood: how the platform creates the org, and how your customizations to the build org definition are turned into deployments and other operations. We'll use this insight to focus on how the customizations we discussed above actually solve their related challenges, and why some of the challenges we discussed are so difficult to address within the build org framework.
