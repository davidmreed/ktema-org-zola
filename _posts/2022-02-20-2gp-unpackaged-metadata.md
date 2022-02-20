---
layout: post
title: What Does `unpackagedMetadata` Do for a Second-Generation Package?
---

Second-generation packaging offers the opportunity to specify [unpackaged metadata for package version creation tests](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_dev2gp_unpackaged_md.htm). It's always been a little unclear to me what this actually meant, and I took a very good [question on Salesforce Stack Exchange](https://salesforce.stackexchange.com/questions/369585/issue-with-dependency-package-picklist-value-not-found/369796#369796) as a chance to find out.

Put simply, the `unpackagedMetadata` directory specified for a second-generation package is deployed into the build scratch org _after_ the package version is created, but _before_ running Apex tests to validate the package version. Let's unpack what that means.

Check out the [`unpackaged-apex-2gp-test`](https://github.com/davidmreed/unpackaged-apex-2gp-test) repo on GitHub to follow along. The repo contains an unpackaged directory (`unpackaged`), which contains a field called `Test__c` on `Account`.

The package directory `works` demonstrates a package build that uses the `unpackagedMetadata` feature to allow the build to test cleanly. The package contains a single Apex unit test:

```lang-java
@isTest
private with sharing class UnpackagedTest {
    @isTest
    private static void unpackagedTestWithDynamicReference() {
        Account a = new Account(Name = 'Foo');
        insert a;

        System.debug(Database.query('SELECT Test__c FROM Account'));
    }
}
```

The critical facet of this code is that it establishes a _runtime_, but not a _compile time_, dependency on the field `Account.Test__c` (which we are not packaging). That's the situation for which `unpackagedMetadata` is designed.

After we create a package

```lang-bash
$ sfdx force:package:create --name UnpackagedTestWorks --nonamespace --packagetype Unlocked --path works
```

If we try right away to create a package version

```lang-bash
$ sfdx force:package:version:create --package UnpackagedTestWorks --installationkeybypass --codecoverage --wait 100
```

it does not work, because the runtime dependency on the `Test__c` field is not satisfied and causes the Apex test to fail (although the dynamic SOQL allows the code to compile).

> ERROR running force:package:version:create:  Apex Test Failure: Class.UnpackagedTest.unpackagedTestWithDynamicReference: line 8, column 1 System.QueryException: No such column 'Test\_\_c' on entity 'Account'. If you are attempting to use a custom field, be sure to append the '\_\_c' after the custom field name. Please reference your WSDL or the describe call for the appropriate names.


By adding the `unpackagedMetadata` key to the package entry in our `sfdx-project.json`:

```lang-json
{
    "path": "works",
    "unpackagedMetadata": {
        "path": "unpackaged"
    }
    // ...
}
```

we obtain a successful package version create:

> Successfully created the package version [08c8c000000XXXXAAO]. Subscriber Package Version Id: 04t8c000000XXXXAAC
Package Installation URL: https://login.salesforce.com/packaging/installPackage.apexp?p0=04t8c000000XXXXAAC

The sequence of events is

1. Dependencies and `objectSettings` configuration (not used here) are deployed into the build org.
2. Package source is deployed into the build org.
3. Package version is created.
4. `unpackagedMetadata` is deployed.
5. Apex tests are executed.

Because the dependency only comes into play in step (5), `unpackagedMetadata` supports this use case.

---

If we use the `does-not-work` package, we can demonstrate that the `unpackagedMetadata` feature does _not_ allow us to satisfy a compile-time dependency. Here's the Apex test from that package:

```lang-java
@isTest
private with sharing class UnpackagedTest {
    @isTest
    private static void unpackagedTestWithExplicitReference() {
        Account a = new Account(Name = 'Foo', Test__c = 1);
        insert a;
    }
}
```

This package cannot be uploaded, with or without the use of `unpackagedMetadata`; either way, we get back an error:

```lang-bash
$ sfdx force:package:create --name UnpackagedTestDoesNotWork --nonamespace --packagetype Unlocked --path does-not-work
$ sfdx force:package:version:create --package UnpackagedTestDoesNotWork --installationkeybypass --codecoverage --wait 100
```

> ERROR running force:package:version:create:  UnpackagedTest: Field does not exist: Test\_\_c on Account

The unpackaged metadata is deployed too late to satisfy this compile-time dependency.

---

The only routes to build a second-generation package that contains an unsatisfied compile-time metadata dependency are 

1. Use an org-dependent Unlocked Package by adding `--orgdependent` to `sfdx force:package:create`. For these packages, metadata validation takes place at install time rather than build time, allowing the metadata dependency to be satisfied in the target org rather than in the build org.
2. Create a Skip Validation 2GP beta by adding `--skipvalidation` to `sfdx force:package:version:create`. This also defers metadata validation to install time. However, Skip Validation packages cannot be promoted to Released state. As such, this strategy is only usable during development and testing, and cannot be used for delivering a package.

The only viable strategy to deliver a _managed_ (as opposed to Unlocked) package that must build with static metadata references to unpackaged metadata is to use first-generation packaging. In 1GP, the referenced unpackaged metadata can be present in the packaging org, but not included in the package itself. This structure results in the dependency being validated at install time.

Adopting this strategy may result in a more challenging user experience at install time, but does allow a package that must include this type of dependency to utilize all the benefits of managed packaging, such as IP protection and AppExchange distribution. [Metadata ETL](https://cumulusci.readthedocs.io/en/stable/metadata_etl.html) in CumulusCI is a strategy that can help address these challenges for first-generation packages.
