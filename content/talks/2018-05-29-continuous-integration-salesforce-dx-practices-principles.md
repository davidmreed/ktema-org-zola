+++
title="Continuous Integration with Salesforce DX: Practices and Principles for All"
aliases=["2018/05/29/phillyforce-continuous-integration-talk.html", "2018/05/06/phillyforce-talk.html", "2018/03/07/phillyforce-ci-talk.html"]
[extra]
venue="Phillyforce '18"
[extra.resources.video]
youtube_id="VLl1uUPF97g"
[extra.resources.repo]
link="https://github.com/davidmreed/circleci-sfdx-examples"
+++

This talk draws on several past articles published here:

 - [Salesforce Lifecycle and Tooling: CircleCI and SFDX](@/articles/2018-02-02-salesforce-dx-circleci.md)
 - [Integrating Static Analysis with PMD in the Salesforce Development Lifecycle](@/articles/2018-02-08-static-analysis-pmd-salesforce.md)
 - [Salesforce Lifecycle and Tooling: Testing on Multiple Org Types with Salesforce DX and CircleCI Workflows](@/articles/2018-03-17-circleci-sfdx-multiple-org-shapes.md)
 - [Integration Testing Off-Platform Code with Salesforce DX and `simple_salesforce`](@/articles/2018-03-27-integration-testing-salesforce-dx-simple-salesforce.md)

Some additional resources and examples are available on my GitHub:

 - [circleci-sfdx-examples](https://github.com/davidmreed/circleci-sfdx-examples), a compendium of [CircleCI](https://circleci.com/)/[Salesforce DX](https://developer.salesforce.com/platform/dx) examples, including a basic project, using the Lightning Testing Service, testing against multiple org shapes, and using PMD static analysis.
 - [sfdx-simplesalesforce](https://github.com/davidmreed/sfdx-simplesalesforce), demonstrating how to test integrated code written in Python with [`simple_salesforce`](https://github.com/simple-salesforce/simple-salesforce) via Salesforce DX scratch orgs.
 - [septaTrains](https://github.com/davidmreed/septaTrains), my toy Lightning project (ever wanted your [SEPTA](http://http://septa.org/) regional rail commute on your Lightning homepage?) and testing project for different CI and automated testing solutions.
 - [DMRNoteAttachmentImporter](https://github.com/davidmreed/DMRNoteAttachmentImporter), a slightly more useful package also building with SFDX on CircleCI.
