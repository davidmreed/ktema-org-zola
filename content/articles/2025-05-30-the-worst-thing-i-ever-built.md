---
title: The Worst Thing I Ever Built
draft: true
---

More than twenty years ago, I cut a corner to save the princely sum of about $200. I am still supporting the technical debt from that decision _today_. This is the story of the worst system I've ever built.

---

My father was already wearing many different hats for our local community association when they had need of a new bookkeeper. He _wasn't_ a bookkeeper, but we were confident we could set him up for it. I was a 17-year-old hobbyist programmer at the time, writing C and Pascal and HTML on a motley and mostly secondhand collection of Macs. (I'd also built the association's website, mercifully since redone - I checked while writing this story). So it fell to me to set up the software for this new job. (I'm sure a measure of hubris was involved on my part).

The first question I had was "what software are we using?" QuickBooks. It's what the organization wanted. Do we have QuickBooks? We do not. But the last person to do this job did, and we can use their copy. Or something. It was never particularly clear. But a copy of QuickBooks 2002 on CD-ROM _did_ turn up. It was out of date even at the time, and more importantly, it was the Windows edition. We were a Mac family. It was also a trial edition. Did someone have the license key? Oh yes, they'll get it to us. (I don't need to tell you how that turned out, do I?)

Scrounging was part of our family ethos. Part of that was not having money to spare, but quite a lot of it was the delight of making something work again or patching together something that worked out of spares. So scrounge I did to make this situation work: my father kicked off his bookkeeping career on

 - QuickBooks 2002,
 - running on Windows 98,
 - on an emulated Pentium II,
 - inside Connectix Virtual PC 3.0,
 - running on MacOS 9,
 - on a Power Macintosh G3.

It ran _very badly_, but it did run, and required the expenditure of $0.

This was 2004 or 2005. Every single piece of this stack was already obsolete, and only got worse from there. QuickBooks was a version or two behind current. Windows 98 was already deep into end-of-life; XP had been out for several years. MacOS 9 had been superseded by the brand-new MacOS X. Connectix had been bought out by Microsoft. Not only was the G3 around 5 years old, but Apple had either just announced or was about to announce the transition from the PowerPC architecture to Intel processors. That last was especially ironic since we were using an old PowerPC to emulate an even older Intel chip.

Over the following couple of years, my father and I developed a collection of tricks to keep this turducken of a workstation running. I discovered how to use `RegEdit` to make that trial version of QuickBooks think it hadn't yet expired. I had my father use the virtual machine's state saving feature to keep our trial version of QuickBooks running as long as possible, so he wouldn't have to go to `RegEdit`. I taught him to backup his work and exfiltrate his backups out of the virtual machine onto a USB drive. And my father, an inveterate and accomplished tinkerer with machines, accumulated a _remarkably_ deep inventory of ever-more-obsolete Power Macintosh G3s, which he switched in and used as spare parts as the aging hardware began to fail.

This went on for _twenty years_.

Twenty years of booting up an ancient Macintosh, then an emulated and excruciatingly slow PC to use obsolete bookkeeping software. Twenty years of trying to keep printer drivers working to print checks from Windows 98 inside Mac OS 9. Twenty years of carefully nursing machines along to keep the engine running.

Even if we'd decided to drop the $200 (or whatever it was) to buy a modern accounting package (maybe even one that ran on MacOS!), we were stuck. QuickBooks' file format changed every couple of years, and one had to incrementally upgrade from version to version. Our data was locked in! That upgrade process was distinctly not in the cards for us, as I left for college and then a career. And besides, the system worked.

... or it did until 2025, when the inevitable finally and quite thoroughly evitted itself. Virtual PC corrupted its saved machine state, and we couldn't get it running again. (It was probably possible, but I no longer had any inkling of how to troubleshoot Virtual PC 3.0 on MacOS 9.2 - least of all by phone from 1,500 miles away). And my father's inventory of Power Macintosh G3s had run out. And his backup machine, a Power Macintosh _G4_, would not run the emulator software.

So here I am, twenty years on. Now _I'm_ (somehow) running QuickBooks 2002, on Windows 98, in a totally different virtual machine on my modern desktop. I'm exporting data from my father's backups with an eye to loading it into _anything else on the planet_.

Because twenty years ago, to save $200, I brought a technical abomination into this world. As such things do, it became a load-bearing abomination. And finally, at a time minimally convenient, it decided to stop bearing.

I don't know that there's a pithy lesson to this story. ("Don't build horrible things"?) But I certainly got what I deserved in the end.
