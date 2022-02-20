---
layout: post
title: What Does `unpackagedMetadata` Do for a Second-Generation Package?
---

Second-generation packaging offers the opportunity to specify [unpackaged metadata for package version creation tests](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_dev2gp_unpackaged_md.htm). It's always been a little unclear to me what this actually meant, and I took a very good [question on Salesforce Stack Exchange](https://salesforce.stackexchange.com/questions/369585/issue-with-dependency-package-picklist-value-not-found/369796#369796) as a chance to find out.

Put simply, the `unpackagedMetadata` directory specified for a second-generation package is deployed into the build scratch org _after_ the package version is created, but _before_ running Apex tests to validate the package version. Let's unpack what that means.


