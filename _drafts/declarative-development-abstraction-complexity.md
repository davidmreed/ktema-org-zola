---
layout: post
title: Declarative Development, Abstraction, and Complexity
---

One is about declarative development and complexity. I'm certain there is academic work here that would be of interest, but I don't know the keywords to search or even the name of the field. I think about it a lot, but I don't know the language of the field to describe it.

The way I think about it is this: as the capabilities of a declarative and a code-based system (or, another way, a low-level system and a higher-level abstracted system) begin to converge, their complexity approaches equality.

We used to have Workflow Rules. They weren't very good: they couldn't do that much, they had unpredictable side effects on the order of execution, caused performance issues, and supported very little logic. 

Then we got Process Builder. It had a little bit of logic - you could do basic branching, and entry conditions to different execution paths. But performance was still a challenge, and Process Builder's weak logic capabilities did as much to whet the appetite for stronger tools than they did to solve the underlying needs.

Now we have Flow. It can do a lot more than Workflow Rules or Process Builder, but it can do a lot more because it's basically a visual programming language. It added complexity to be able to cover more of the unboundedly vast scale of _things people want to do_. And it's still not enough, so it needs to be extended with Apex. It's a huge win for declarative developers, but in a sense it is also a victim of its own success: capabilities bring complexity.

That links to the second thread: abstractions.

There's (at least) three problems when you use a system that abstracts a lower level system (and nearly all systems, by nature, do!)

One is that the abstraction is _incomplete_: there are things achievable at the lower level that are not achievable at the higher level.

Another is that the abstraction is _leaky_: you end up needing to _know_ the lower level, because the abstraction is not able to effectively hide the behavior of the lower-level system over which it abstracts.

A third is agility. Because low-level systems have small, low-level elements, they go stale slowly: the high-level systems implemented _with_ them change, but they do not. But abstractions, as they become higher and higher level, cannot evolve as quickly. An end-user-facing system built directly on the lowest level of abstraction (code, here) can pivot quickly as new capabilities become available, but it costs more for it to do so. An end-user-facing system built on an abstraction layer must wait as the world evolves around it for the abstraction too to be updated, exposing new capabilities or metaphors or strategies for it to use. The abstraction goes stale.
