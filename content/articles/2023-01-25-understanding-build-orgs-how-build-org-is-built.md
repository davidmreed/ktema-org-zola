+++
title="Understanding Build Orgs, Part 2: How a Build Org is Built"
[extra.resources.repo]
link="https://github.com/davidmreed/Build-Org-Examples"
+++

> This discussion is derived only from my experience building packages, writing packaging clients via the public API, and inspecting the public source code of the `sfdx` CLI. No internal or proprietary information about the Salesforce packaging system is included.

In [Part 1](@/articles/2023-01-24-understanding-build-orgs-environmental-dependencies.md) and in a previous discussion of [build orgs and runtime dependencies](@/articles/2022-02-20-2gp-unpackaged-metadata.md), we looked at how the platform provides a number of different tools to handle environmental dependencies and runtime dependencies in second-generation packages by modifying the configuration of the _build org_. We also called out that, with regard to the build org,

> you can't see it or interact with it. ... When you create a package version, your source is deployed to your build org, and your package artifact is uploaded from there. Then, the build org is disposed by the platform.

What's in between those two endpoints — your configuration file in source control, and the uploaded package artifact? Why do we need to apply different strategies for different types of environmental dependency, as we saw in Part 1? And what's up with those dangling threads from before, about `objectSettings` that aren't really `Settings` and about the tricky case of a package with a dependency on another package's Record Type feature? We'll explore all of those questions by digging into the API used to upload 2GP versions, and open up some further avenues for experimentation along the way.

The first stop in digging deeper is the Tooling API. The Tooling sObject [`Package2VersionCreateRequest`](https://developer.salesforce.com/docs/atlas.en-us.api_tooling.meta/api_tooling/tooling_api_objects_package2versioncreaterequest.htm) mediates the process of creating a package version for tools like SFDX and CumulusCI. The tool creates a record in that sObject with input data about the package version desired, and then polls the created records for updates from the platform on the creation process.

There are two fields on this object that directly control the build org generation process:

`SourceOrg` is documented as:

> The ID of the org whose shape (features, settings, limits, and licenses) information is used for creating scratch orgs used to validate metadata during creation of a second-generation managed package or unlocked package.

We looked at the Org Shape feature briefly in Part 1. For unclear reasons, build orgs that use an Org Shape are set here rather than with the remaining parameters (discussed below).

`VersionInfo` is documented as:

> The blob that stores details about the package version.

That's rather obscure - but there's nowhere else for the scratch org definition information to go, so it must be part of `VersionInfo`!  As far as I'm aware, the structure of the `VersionInfo` blob isn't documented formally and could change at any time, but we can reverse-engineer quite a bit about how it works. 

## Unraveling `VersionInfo`

> This article is _not_ Salesforce documentation! Behaviors described here could change at any time. 

Since [`sfdx` is open source](https://github.com/salesforcecli/sfdx-cli), we can pop the hood and find out quite a bit about how `VersionInfo` is created. What we want, specifically, is the [`@salesforce/packaging`](https://github.com/forcedotcom/packaging) NPM package, used by the [`plugin-packaging`](https://github.com/salesforcecli/plugin-packaging) SFDX plugin, which itself implements the `force:package:version:create` command. The relevant code's [here](https://github.com/forcedotcom/packaging/blob/main/src/package/packageVersionCreate.ts#L340). I'll save you parsing through some moderately abstract TypeScript and describe what happens, as of this writing.

The value of the `VersionInfo` field is a ZIP file encoded in base64, which shouldn't be a surprise to anyone used to working with the Metadata API. Its contents are a bit surprising, however. The ZIP file contains four members, as follows.

### The Package Descriptor

`package2-descriptor.json` is a specification of both the version to be created and of the build org. It is _not_ a scratch org definition file. Rather, it's a fusion of information about the package itself (derived from `sfdx-project.json`) and information about the build org (derived from the scratch org definition file). 

The schema for the descriptor, as far as I can tell, is this:
 
```typescript
type PackageDescriptor = {
  // Values derived from package definition in sfdx-project.json
  // These values are post-processed, not copied literally -
  // for example, dependencies are resolved to an 04t SubscriberPackageVersionId.
  package2Id: string;
  dependencies?: { subscriberPackageVersionId: string }[];
  ancestorId?: string;
  postInstallScript?: string;
  postInstallUrl?: string;
  releaseNotesUrl?: string;
  uninstallScript?: string;
  versionDescription?: string;
  versionName?: string;
  versionNumber?: string;

  // Values derived from scratch org definition file
  features?: string[];
  // orgPreferences is deprecated; use `settings` instead.
  orgPreferences?: string[];
  snapshot?: string;
  sourceOrg?: string;
  country?: string;
  edition?: string;
  release?: string;
  language?: string; 

  permissionSetNames: string[];
  permissionSetLicenseDeveloperNames: string[];

  // It's not particularly clear to me what this does (we set it to "" in CumulusCI)
  path: string;
};
```

There's a source of some confusion here: the descriptor includes multiple fields that are duplicated from the top-level `Package2VersionCreateRequest` sObject.

- `Language`
- `SourceOrg`

For `SourceOrg`, the field value at the `Package2VersionCreateRequest` takes precedence. I verified this by creating otherwise-valid `Package2VersionCreateRequest` objects with _different_ `SourceOrg` fields in the descriptor and in the base sObject field. One of those values was a valid source org and one of them was not. Since I received the error

> The source org specified for the package version was not found or invalid. Source Org ID : 00D000000000000.

only when I placed the invalid `SourceOrg` value was at the `Package2VersionCreateRequest` level, I surmised that that field value takes precedence.

I've not yet been able to determine how the different `Language` values are handled.

The `orgPreferences` scratch org definition key is deprecated in favor of using more specific Metadata API `Settings` entities, although the SFDX CLI will still send it to the API if it's present. I wouldn't rely on the key in this descriptor working or continuing to work for that reason. (I did not experimentally verify if it works today).

### Package Content
 
`package.zip` is a ZIP file containing the package metadata, in Metadata API format. This is the same type of artifact that you would upload when performing any Metadata API deployment, whether or not you're creating a package version. 

### Settings Bundle
 
`settings.zip` contains metadata, in Metadata API format, synthesized from the `settings` and `objectSettings` keys in the scratch org definition file. The SFDX CLI implements that synthesis [here](https://github.com/forcedotcom/sfdx-core/blob/b4c4e90898cf62083babfdd54cc33950f37d6e85/src/org/scratchOrgSettingsGenerator.ts), and CumulusCI implements it [here](https://github.com/SFDO-Tooling/CumulusCI/blob/3ff1aa8794e5c7ba5e330bbfc5a0d6f5af1f9021/cumulusci/tasks/salesforce/org_settings.py#L74).

Entries under `settings` are converted one-for-one to Metadata API `Settings` entities. For example,

```json
"settings": {
  "enhancedNotesSettings": {
    "enableEnhancedNotes": true
  }
}
```

would translate to XML metadata like this, in `settings/EnhancedNotesSettings.settings`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<EnhancedNotesSettings xmlns="http://soap.sforce.com/2006/04/metadata">
  <enableEnhancedNotes>true</enableEnhancedNotes>
</EnhancedNotesSettings>
```

`objectSettings` entries are translated into `CustomObject` metadata. For example, 

```json
"objectSettings": {
  "account": {
    "defaultRecordType": "default",
	"sharingModel": "private"
  }
}
```

would translate to XML metadata like this, in `objects/Account.object`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Object xmlns="http://soap.sforce.com/2006/04/metadata">
  <sharingModel>Private</sharingModel>
  <recordTypes>
    <fullName>Default</fullName>
    <label>Default</label>
    <active>true</active>
  </recordTypes>
</Object>
```

Notice that this is not a complete object definition. It only contains the customizations layered on top of the standard object. If the object named in `objectSettings` doesn't exist in the org, we'll get a confusing error:

```
ERROR running force:package:version:create:  Sample__c: Must specify a non-empty label for the CustomObject
```

The error makes sense when we look at the actual, deployed metadata: the metadata doesn't have the required label specified, because it's intended to be deployed _over an object that already exists_. In this case, the object doesn't exist, so the Metadata API interprets our deployment as an attempt to create an object. This behavior will become important below in teasing out the order of operations.

The `settings.zip` member is optional.

### Unpackaged Metadata Bundle
 
`unpackaged-metadata-package.zip` contains arbitrary metadata that supports Apex test execution, but isn't included in the package itself. This bundle allows us to satisfy runtime dependencies of our Apex tests, without including test metadata in the package itself. Its content is completely user-specified.

The `unpackaged-metadata-package.zip` member is optional.

## Probing the Black Box

When this multi-layered ZIP file is sent to the platform as part of a `Package2VersionCreateRequest`, the packaging system takes over. At that point, we can no longer inspect the state of the process directly. What we get back is only the status set on the record by the platform, along with any error message that's thrown. However, we can infer quite a bit about the behaviors of the packaging system by close attention to the behaviors we saw in previous installments of this series, and by careful experiments.

Org creation, by nature, must take place first.

Feature application happens second. We know this happens before settings deployment, because we can deploy settings that configure features, and we can do so if and only if the feature is actually enabled in the org. The experiment to demonstrate this is tricky to run because of how many features are turned on by default in a Developer Edition scratch org, but I've tested it in both build orgs and regular scratch orgs to validate that features are applied before settings.

`settings.zip` is deployed next. We know this happens before dependency package installation because we _cannot_ use `objectSettings`, which is converted into metadata in `settings.zip`, to create a default Record Type on an object that's owned by a dependency package. We can demonstrate this via the package in `dependency-record-types` in the repo. When we do

```
sfdx force:package:version:create -d dependency-package-record-types -x -f config/with-dependency-record-type.json -w 100
```

we get back the same error we saw above, when the object named in `objectSettings` doesn't exist:

```
ERROR running force:package:version:create:  Sample__c: Must specify a non-empty label for the CustomObject
```

Hence, `settings.zip` is deployed first, followed by dependency packages.

All of the initial setup being complete, the package metadata is deployed next.

Two elements of the build org are aimed at runtime dependencies: Permission Set and Permission Set License assignments, and unpackaged metadata (the confusingly-named member `unpackaged-metadata-package.zip`). We know that these items are deployed after the package metadata, because we cannot use unpackaged metadata to satisfy references in the 2GP package itself. (We demonstrated this in [our examination of runtime dependencies](@/articles/2022-02-20-2gp-unpackaged-metadata.md)). We don't know whether Permission Set (License) assignment happens first, or unmanaged metadata deployment. This might make a difference in certain edge cases, but I've so far been unable to devise an experiment to validate the internal order of this step.

Apex tests are always run before a package is uploaded, unless an option such as Skip Validation is used. We also know Apex tests are run after unpackaged metadata deployment, because we can use unpackaged metadata to satisfy dynamic references in Apex tests.

Finally, the package artifact is created, and the build org is disposed.

## Build Org Sequence of Operations

With all these experiments giving us a peek inside the black box, here's the order of operations that takes place in the build org when we upload a second-generation package version:

1. The build org is created. 
    - If a source org or snapshot is being used, that element defines the org.
    - Otherwise, the specified edition is used. 
2. Features are applied to the org. This is _not_ an API-based operation; it's part of the black box.
3. The settings bundle (`settings.zip`) is deployed.
4. Dependency packages are installed.
5. The package metadata is deployed (`package.zip`).
6. Runtime dependency setup is performed, if present. It's unclear in which order these two steps are performed, although the order will make a difference only in a handful of edge cases.
    - The unpackaged metadata bundle (`unpackaged-metadata-package.zip`) is deployed. 
	- Permission Sets and Permission Set Licenses are assigned.
7. Apex tests are run in the org.
8. The package artifact is created.
9. The build org is disposed.

## Implications and Next Steps

Let's think through the implications of this knowledge.

The 2GP build org system gives us tools to handle:

- Feature dependencies (build org definition)
- Environmental dependencies (`settings.zip`)
- Package dependencies (dependencies)
- Runtime dependencies (`unpackaged-metadata-package.zip`)

While we've got a handful of outstanding edge cases, the vast majority of dependencies can be satisfied by applying these tools. However, the fixed order of deployment in build org creation means that we have limited ability to address edge cases or unforeseen circumstances. For example, we cannot perform an unpackaged metadata deployment after dependency packages, but before package metadata deployment. This is what we'd need in order to serve the package-with-dependency-record-type issue without using an org snapshot.

We can't perform arbitrary API-based operations on the org. We never get direct access with a session id. That means we still don't have a clear way to handle environmental dependencies on things like Standard Value Sets, which cannot be packaged.

But ... there's a thread we can pull on here. In Step 3, the settings bundle is deployed into the org. We know that `settings.zip` is synthesized by the SFDX CLI from `settings` and `objectSettings` into Metadata API-format source. But that behavior is client-side, not part of the API as such. What if we could talk directly to the API, and put _something other than those elements_ into `settings.zip`? That would give us some interesting new ways to use this capability, and close an edge case or two.

Stay tuned for Part 3 of this series.