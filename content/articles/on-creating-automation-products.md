+++
title="On Creating Automation Products"
draft=true
+++

The most important skill I learned from [Jason Lantz](https://muselab.com/) was seeing *products* hiding inside business problems that are usually addressed with *tools*. It's the keystone of the success of the team that created [CumulusCI](https://cumulusci.readthedocs.io), [MetaDeploy](), [Metecho](), and a number of other automation-focused products for teams building on Salesforce. It's also a subtle distinction, between *products* and *tools*. I've been slowly turning over this attempt to elucidate that distinction and how it's brought into practice for most of 2023.

I'm going to frame this as two sets of threes: three shapes that an automation effort can take; and three perspective shifts that stakeholders move through in an automation effort. That kind of matrix structure has a bit of "Conjoined Triangles of Success" flavor to it. It appeals to me because it echoes the classic rhetorical trope of the [_tricolon_](https://en.wikipedia.org/wiki/Isocolon#Tricolon).

Jason might articulate this quite differently than I do: the formulation here is mine, but the vision is his.

## Automation Processes



1. Take a manual process and automate the individual steps.

Usually, this approach means there are still people's hands on the keyboard - they're just running one command instead of 20. Cost improvement can be significant, but this approach often leaves transformative opportunities on the table.

When a process is in this state, it's common for users to do a great deal of context-switching or waiting for a step to complete so that they can initiate a next step. Out-of-band information transfers between different users is also common, as are high-attention monitoring routines that reflect low overall confidence in the process.

2. Automate the outcome of the process, which might radically change its shape.

Submerge all of those operational touchpoints! Automate the journey between the start and end of the process, _proactively_ pulling in users only when their intervention is needed. Start thinking in dashboards instead of buttons, and monitoring failures instead of operations. Assume that the process succeeds, and notify only when it doesn't.

This is where you start to get transformative change: humans freed to do creative, strategic work instead of operations.

3. Discover and automate the ultimate business goal of the process, which might entail deleting the process entirely.

What if the end of the process isn't really the end - the goal - of the whole shebang? The most satisfying insight can be that the entire process does not need to exist. Take a different path - a shortening of the way, if you will - to achieve that larger outcome. That change can reshape other processes around it, too.


## Perspective Shifts

Much more often, it's about perceiving and helping stakeholders make one or more of three critical shifts:

1. To move from a "how" understanding of their process to a "why" understanding - unlocking a new "how".

I find that this is very common in operations teams and in teams that are primarily focused on compliance objectives.

1. To move from a keyhole view of a business process or objective to a holistic one.

This is a common paradigm shift for teams with very mature manual processes that are executed at scale. Individual workers aren't privileged to see the whole; only their own parts.

1. To understand their process or challenge as an instance of a much more general one.

It's about seeing the haunting possibility inside a problem that's just barely the wrong shape, and those three shifts make it possible to realize the possibility.

With the first shift, you focus on value and outcome, rather than implementation. Implementation often becomes ossified: "we've always done it this way". It takes trust to make this shift, but that trust can be won by focusing on the shared value of the outcome.

With the second shift, you embrace all of the other people and data flows that accrue towards that shared goal.

With the third, 

## Tools and Products

The distinction between a *tool* and a *product* almost never has anything to do with scale, with technology stack, or with ... I can't think of a single instance when a colleague presented me with a business problem and the "product" answer was "Yeah, but let's do that at web scale", or "Yeah, but let's build it in React." You can build narrow, non-product solutions to business problems in any stack, and scale them as high as you want. They're still not products.

It's much more to do with how you frame what you are building. Are you going to the root of the business problem? Are you imagining the general problem of which this is an instance? Are you inviting, persuading, cajoling your stakeholders to reimagine how they could reach their goals? You're probably building a product. Are you reifying the way things are done today in code? Are you spending effort more on edge cases than capabilities? Do you understand the _what_, but not the _why_, of what you're creating? You're likely building a tool.

There's nothing wrong with building tools. Sometimes it's the right move: you can generate a lot of cost savings and business value, often at a relatively low upfront cost. But products are far more interesting. And in the best case, you can achieve a great deal more value, at only modest increase in total cost, and with significantly lower long-term costs.