+++
title="On the Problems with TSOs"
draft=true
+++

One of the most common methods of distributing Salesforce orgs and packages is the _TSO_: a _Trialforce Source Org_.

## Use Cases

- Customer delivery
- QA
- License replication

## The Source-of-Truth Problem

Modern development projects focus on version control as the _source of truth_: the canonical definition of what's in your product. But TSOs blur that line. If y

## TSO as Binary Blob

A "binary blob", in software engineering, refers to a component that cannot be inspected. It's provided only as an opaque binary. You can execute that binary to do work, but you cannot look inside it to see what makes it tick and how it's implemented.

Binary blobs pose a number of challenges in the SDLC. 

## TSO as Agility Blocker

TSOs can deliver only new orgs. There is no such thing as a modular TSO; you cannot layer a TSO on top of an existing org. That means that the effort cliff on composability is a vertical line.

## Org Snapshots

Org Snapshots are much 

## TSOs and Org Snapshots as Operational Tool

## Source-Driven TSOs

I've said a lot against TSOs. Let me say one thing for them: TSOs work well for their core purpose, which is generating a new org for a user or customer. The `SignupRequest` API is simple to use and the process is effective.

We can consume that core function of the TSO without sacrificing our SDLC goals - without incurring all of the problems discussed above. We do that by using a _source-driven TSO_ model.