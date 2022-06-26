---
layout: post
title: Mysteries of the Access Token
---

1. Is performing an OAuth token refresh thread-safe?
2. If one executes a token refresh multiple times,
  1. Is the same valid token returned?
  1. If no, do all tokens remain valid with their own lifetimes?
  1. If no, is there a limit to how many threads can have their own tokens?