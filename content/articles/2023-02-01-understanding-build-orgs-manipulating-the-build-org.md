+++
title="Understanding Build Orgs, Part 3: Manipulating the Build Org"
draft=true
[extra.resources.repo]
link="https://github.com/davidmreed/Build-Org-Examples"
+++

> This discussion is derived only from my experience building packages, writing packaging clients via the public API, and inspecting the public source code of the `sfdx` CLI. No internal or proprietary information about the Salesforce packaging system is included.

This third part of the series, which began with [Understanding Build Orgs: Environmental Dependencies](@/articles/2023-01-24-understanding-build-orgs-environmental-dependencies.md), [What does `unpackagedMetadata` do for a 2GP?](@/articles/2022-02-20-2gp-unpackaged-metadata.md), and [Understanding Build Orgs: How a Build Org is Built](@/articles/2023-01-31-understanding-build-orgs-how-build-org-is-built.md), brings us to a close by getting as deep into the guts of the second-generation package (2GP) build org as we can get. Specifically, we'll tease out a thread we found at the end of Part 2: the fact that there's a Metadata API ZIP payload deployed into the build org before our packaged source.

Let's recall from Part 1 and 2 that there are a couple of thorny edge cases in terms of environmental dependencies that we haven't yet figured out how to serve, or serve well:

- Packages that have dependencies on the Record Type feature for an sObject owned by another package.
- Packages that have dependencies on Standard Value Set entries.

In Part 2, we observed

> ... the settings bundle is deployed into the org. We know that `settings.zip` is synthesized by the SFDX CLI from `settings` and `objectSettings` into Metadata API-format source. But that behavior is client-side, not part of the API as such. What if we could talk directly to the API, and put _something other than those elements_ into `settings.zip`?

Let's dig into that possibility and see if it helps address our complicated use cases.

---

To do this experiment, I'm using CumulusCI, because it's easier for me to hack on. CumulusCI's package upload semantics are a little bit different than those of SFDX, but for our purposes, we don't need to worry much about the differences. We'll use the `create_package_version` task. That task already implements package upload by creating `Package2VersionRequest` records, and it already re-implements the strategy used by the SFDX CLI to turn `objectSettings` into `settings.zip`. Let's see what happens if we change that logic around a bit.

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

