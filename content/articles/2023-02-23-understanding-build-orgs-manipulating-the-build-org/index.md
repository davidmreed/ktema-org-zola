+++
title="Understanding Build Orgs, Part 3: Manipulating the Build Org"
draft=true
[taxonomies]
series=["Understanding Build Orgs"]
[extra.resources.repo]
link="https://github.com/davidmreed/Build-Org-Examples"
+++

> This discussion is derived only from my experience building packages, writing packaging clients via the public API, and inspecting the public source code of the `sfdx` CLI. No internal or proprietary information about the Salesforce packaging system is included.

This third part of the series, which began with [Understanding Build Orgs: Environmental Dependencies](@/articles/2023-01-24-understanding-build-orgs-environmental-dependencies.md), [What does `unpackagedMetadata` do for a 2GP?](@/articles/2022-02-20-2gp-unpackaged-metadata.md), and [Understanding Build Orgs: How a Build Org is Built](@/articles/2023-01-31-understanding-build-orgs-how-build-org-is-built.md), brings us to a close by getting as deep into the guts of the second-generation package (2GP) build org as we can get. Specifically, we'll tease out a thread we found at the end of Part 2: the fact that there's a Metadata API ZIP payload deployed into the build org before our packaged source.

Let's recall from Part 1 and 2 that there are a couple of thorny edge cases in terms of environmental dependencies that we haven't yet figured out how to serve, or serve well. In particular, we'll follow up on the challenge of packages that have dependencies on Standard Value Set entries.

In Part 2, we observed

> ... the settings bundle is deployed into the org. We know that `settings.zip` is synthesized by the SFDX CLI from `settings` and `objectSettings` into Metadata API-format source. But that behavior is client-side, not part of the API as such. What if we could talk directly to the API, and put _something other than those elements_ into `settings.zip`?

Let's dig into that possibility and see if it helps address our complicated use cases.

---

To do this experiment, I'm using CumulusCI, because it's easier for me to hack on. We'll need to actually make some code changes to run experiments against the behavior of `settings.zip`. If you're not a Python engineer, that's fine! I'll walk through the contours of how we get this test ability. 

CumulusCI's package upload semantics are a little bit different than those of SFDX, but for our purposes, we don't need to worry much about the differences. We'll use the `create_package_version` task. That task already implements package upload by creating `Package2VersionRequest` records, and it already re-implements the strategy used by the SFDX CLI to turn `objectSettings` into `settings.zip`. Let's see what happens if we change that logic around a bit.

Working around line 400, in the logic that constructs a `Package2VersionRequest`, we drop a little extra code:

```python
if "settings_metadata_path" in self.options:
  path = self.options["settings_metadata_path"]
  with convert_sfdx_source(path, "", self.logger) as src_path:
    package_zip_builder = MetadataPackageZipBuilder(
      path=src_path,
      context=self.context,
    )
    version_info.writestr(
      "settings.zip", package_zip_builder.as_bytes()
    )
```

This code looks for a new option, `settings_metadata_path`. If there's a path given, it _ignores_ the `settings` and `objectSettings` keys in the build org definition, and instead reads metadata directly from disk into the `settings.zip` member of our `VersionInfo` blob.

That gives us a route to pipe whatever metadata we wish into the API. Let's see what the API chooses to do with it.

We'll go back to the `standard-value-sets` example. Recall that the original behavior we saw was this:

```
cci task run create_package_version \
  --package-name "Standard-Value-Sets" \
  --package-type Unlocked  \
  --org dev
```

```
[02/22/23 21:19:21] [Error]: Package creation failed with error: 
  Error: Case.Customer Support Case: Picklist value: Evaluating not found
```

Let's see if we can get that package to create by stuffing some extra metadata in `settings.zip`.

We add a new metadata directory, `standard-value-sets-unpackaged`. We include this metadata in that directory as `standardValueSets/CaseStatus.standardValueSet-meta.xml`, configuring the Case Status picklist to match expectations.

```
<?xml version="1.0" encoding="UTF-8"?>
<StandardValueSet xmlns="http://soap.sforce.com/2006/04/metadata">
    <sorted>false</sorted>
    <standardValue>
        <fullName>New</fullName>
        <default>true</default>
        <label>New</label>
        <closed>false</closed>
    </standardValue>
    <standardValue>
        <fullName>Working</fullName>
        <default>false</default>
        <label>Working</label>
        <closed>false</closed>
    </standardValue>
    <standardValue>
        <fullName>Escalated</fullName>
        <default>false</default>
        <label>Escalated</label>
        <closed>false</closed>
    </standardValue>
    <standardValue>
        <fullName>Closed</fullName>
        <default>false</default>
        <label>Closed</label>
        <closed>true</closed>
    </standardValue>
    <standardValue>
        <fullName>Evaluating</fullName>
        <default>false</default>
        <label>Evaluating</label>
        <closed>true</closed>
    </standardValue>
</StandardValueSet>
```

Now, if I use my new code to inject this metadata into the build org as `settings.zip`:

```
cci task run create_package_version \
  --package-name "Standard-Value-Sets" \
  --package-type Unlocked  \
  --org dev \
  --force-upload True \
  --settings-metadata-path standard-value-sets-unpackaged
```

I get back:

```
[02/22/23 21:22:24] Created package version:
  Package2 Id: 0Ho4p0000000xxxCAQ
  Package2Version Id: 05i4p0000000xxxAAM
  SubscriberPackageVersion Id: 04t4p0000020xxxAAA
  Version Number: 0.0.0.2
  Dependencies: []
```

Sure enough - the platform deployed my Case Status metadata during the build, and it satisfied my build-time dependency on that `Evaluating` picklist value.

Did it _work_? Is the package actually viable? Let's set up an org with the picklist values we want, and install the package:

```
cci task run deploy --path standard-value-sets-unpackaged --org dev
cci task run install_managed --version 04t4p0000020xxxAAA --org dev
```

```
Installing Package 04t4p0000020xxxAAA
[02/22/23 21:41:59] In Progress
[02/22/23 21:42:02] Success
```

Here's what we find under Support Processes in Setup:

Our picklist value reference _is_ in the package! 

---

Where does this leave us?

Well, it's an interesting capability we've discovered: injecting any metadata we like into the 2GP build org. It gives us another view into the build process, and reinforces a link between the 1GP and 2GP stories. We could, of course, do this same thing with a 1GP packaging org!

I wouldn't rely on it for a production 2GP managed package. This behavior is undocumented and not committed. It could certainly change tomorrow. But if's a technique I will keep in my back pocket when, as is often the case, [I'm experimenting with 2GPs as testing tools](https://medium.com/salesforce-architects/find-bugs-earlier-with-second-generation-packaging-f7c7a0b5300a).

And it's just kind of neat.