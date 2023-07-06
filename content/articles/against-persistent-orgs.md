+++
title="Against Persistent Orgs"
draft=true
+++

How many persistent orgs do you use in the SDLC for a #Salesforce managed package?

For a 2GP, there should be exactly two: the Dev Hub and the namespace org.
For a 1GP, there should be exactly one: the packaging org.

No Developer Editions. No persistent QA orgs. No integration orgs. Every persistent org being maintained in the SDLC is:

## Process Bottleneck

- a process bottleneck that prevents self-service operations;

## Configuration Skew

- a source of false-negative issues based on configuration skew;

## Black Box or Binary Blob

- a black box that conceals state and makes it harder to explain the product;

## Disaster-Recovery Risk

- a long-term risk with no disaster-recovery capabilities.

## Mitigation

Invest in scratch orgs with fully automated setup to mitigate these risks.

## Exceptions

(Notable exceptions where applicable: TSOs for customer delivery [not operational use!] and LDV sandboxes, as these use cases cannot yet be served by scratch orgs. Drive their state with automation anyway!)
