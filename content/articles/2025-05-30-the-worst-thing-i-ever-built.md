---
title: The Worst Thing I Ever Built
draft: true
---

More than twenty years ago, I cut a corner. Well, I was complicit in a corner's being cut, to save the princely sum of about $200. I am still supporting the technical debt from that decision _today_. This is the story of the worst system I ever built.

---

Growing up, my family never had much money. (I was in my teens in this story). My father had a chance to make a little extra doing bookkeeping work for a local community association, and of course he took it. I was a hobbyist programmer at the time, writing C and Pascal and HTML on a motley and mostly secondhand collection of Macs. (I'd also built the association's website, mercifully since redone - I checked while writing this story). In that light, I stepped in to help set up this little accounting business.

The first question I had was "what software are we using?" QuickBooks. It's what the organization wanted. Do we have QuickBooks? We do not. But the last person to do this job did, and we can use their copy. Or something. It was never particularly clear. But a copy of QuickBooks 2002 on CD-ROM _did_ turn up. It was out of date even at the time, and more importantly, it was the Windows edition. We were a Mac family. It was also a trial edition. Did someone have the license key? Oh yes, they'll get it to us. (I don't need to tell you how that turned out, do I?)

Scrounging was part of the family ethos. Part of that was not having money, but quite a lot of it was the delight of making something work again or patching together something that worked out of spares. So scrounge I did, and my father kicked off his bookkeeping career on

 - QuickBooks 2002,
 - running on Windows 98,
 - on an emulated Pentium II,
 - inside Connectix Virtual PC 3.0,
 - running on MacOS 9,
 - on a Power Macintosh G3.

It ran _very badly_, but it did run, and required the expenditure of $0.

It was 2004 or 2005. Every single piece of this stack was already obsolete at that time, and only got worse from there. QuickBooks was a version or two behind current. Windows 98 was already deep into end-of-life; XP had been out for several years. MacOS 9 had been superseded by the brand-new MacOS X. Connectix had been bought out by Microsoft. Not only was the G3 circa 5 years old, but Apple had either just announced or was about to announce the transition from the PowerPC architecture to Intel processors. That last was especially ironic since we were using an old PowerPC to emulate an even older _Intel_ chip.

Over the following couple of years, my father and I developed a collection of tricks to keep this ridiculous turducken of a workstation running. I discovered how to use `RegEdit` to make that trial version of QuickBooks think it hadn't yet expired. I had my father use the virtual machine's state saving feature to keep our trial version of QuickBooks running as long as possible, so he wouldn't have to go to `RegEdit`. I taught him to backup his work and exfiltrate his backups out of the virtual machine onto a USB drive. And my father, who always liked tinkering with machines but wasn't much for software, accumulated a surprising inventory of ever-more-obsolete Power Macintosh G3s, which he switched in and used as spare parts as the aging hardware began to fail.

This went on for _twenty years_.

Twenty years of booting up an ancient Macintosh, then an emulated and excruciatingly slow PC to use obsolete bookkeeping software. Twenty years of trying to keep printer drivers working to print checks from Windows 98. Twenty years of carefully nursing machines along to keep the engine running.

Even if we'd decided to drop the $200 (or whatever it was) to buy a modern accounting package (maybe even one that ran on MacOS!), we were stuck. QuickBooks' file format changed every couple of years, and one had to incrementally upgrade from version to version. With me having left for college and then a career, and my father having neither the software nor the inclination, we never climbed that hill.

... or we didn't until 2025, when the inevitable finally and quite thoroughly evitted itself. Virtual PC corrupted its saved machine state, and we couldn't get it running again. (It was probably possible, but I no longer had any inkling of how to troubleshoot Virtual PC 3.0 on MacOS 9.2 - least of all by phone from 1,500 miles away). And my father's inventory of Power Macintosh G3s had run out. And his backup machine, a Power Macintosh _G4_, would not run the emulator software.

So here I am, twenty years on. Now _I'm_ running QuickBooks 2002, in a totally different virtual machine on my modern desktop, so I can export data from my father's backups and attempt to load it into _anything else on the planet_ capable of doing simple bookkeeping tasks.

Because twenty years ago, to save $200, I brought a technical abomination into this world. As such things do, it became a load-bearing abomination. And finally, at a time minimally convenient, it decided to stop bearing.

I don't know that there's a pithy lesson to this story. ("Don't build horrible things"?) But I certainly got what I deserved in the end.
