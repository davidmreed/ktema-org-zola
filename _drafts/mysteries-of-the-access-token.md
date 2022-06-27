---
layout: post
title: Mysteries of the Access Token
---

I write a lot of applications integrated to the Salesforce API. Historically, most of them have been single-threaded, but lately I've been working on tools that are async, multithreaded, and distributed. Those architectures bring to the fore some questions I've wondered about but have never satisfactorily answered about how OAuth works in a distributed system.

Let's say I've authenticated to some Salesforce org using the Web Server flow, so I'm holding a refresh token and an access token. I'm running a variety of jobs against this org. Some are scheduled; some are long-running; some are one-off. These jobs run in different containers throughout my distributed application, and some might run in parallel threads on the same container.

Here's what I need to know:

1. In each job, can I safely perform an OAuth token refresh without impacting other jobs?
1. If multiple jobs simultaneously receive an error indicating the access token is expired, can both jobs run an OAuth token refresh safely?
1. If one executes a token refresh multiple times,
  1. Is the same valid token returned?
  1. If no, do all tokens remain valid with their own lifetimes?
  1. If no, is there a limit to how many threads can have their own tokens?


