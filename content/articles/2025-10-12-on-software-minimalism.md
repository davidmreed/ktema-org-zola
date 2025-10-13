+++
title="On Minimalism in Software"
+++

_Please stop calling software minimalist_. It does not mean very much, and it suppresses productive and inclusive discussion of the choices we make when we build software.

---

I see these descriptions all the time. Project A is a "minimalist window manager". Project B is a "minimal but featureful RSS reader". Project C offers "everything you need, without all the bloat". D "does one thing and does it well". It's commonplace to the point of cliche to trumpet one's software as superior because of how finely-targeted it is to some niche, because it lacks all that is not required, because it scythes away features offered by competitors.

What exactly does any of this mean?

Calling a piece of software "minimalist" is a claim about _alignment_. It asserts that the scope of the software is aligned to the category or use case into which that software falls. All three of the examples above read this way; I find that virtually all of the minimalism discourse I encounter in software does too.

That's a problem because "categories" and "use cases", or "genres" or "niches" or whatever we want to call the concepts we use to group similar pieces of software, have no reality of their own. They're conventional. And like all conventions, they vary not just from community to community but from person to person within a community.

Even saying that a tool "does one thing" is an assertion about the scope of that "one thing". Take a command-line music player. It plays files from a directory given on the command line; it has no library management features, no API, no visualization.

What's it's "one thing"? Is it playing music? Or playing MP3 files? Maybe FLAC files are surplus to requirements. But my whole library is FLAC - where's that leave me? Do we need to worry about - or even _know_ about - the differences between ALSA and PulseAudio and PipeWire? Is supporting more than one non-minimal, or is that part and parcel of doing our one thing?

What about audiobooks? If we store audiobooks in a slightly different directory structure, or with slightly different tags, but the same audio format, how does that interact with our definition of the scope of this tool?

(We haven't even _mentioned_ accessibility, which is often a great angle to highlight how some users' needs push on the boundaries we draw around pieces of software).

So when I assert that Software A is minimal for Category B, I'm really making two claims. One is the claim of alignment: A doesn't include anything that's not in B. The deeper claim, which is not made explicit, is a claim about _what Category B is_. It's a claim that the way I use "music player", "window manager", or "terminal emulator", or "messenger", or "BitTorrent client", is a true and universal definition of the category, and that the lines _I_ draw between what's "in" or "out" of that concept are the right ones.

And that's a much more radical claim. _Asserting minimalism elevates convention and preference to universal truth_.

Does that mean the software is bad or wrong, or that it's bad and wrong to build towards a well-bounded vision? Not at all. Notionally minimalist software may indeed be excellent software. But being "minimal" is not why it's excellent. It's excellent because it fulfils a design vision or a use case well, which is what underlies the claim of minimalism.

_Articulate that design vision, use case, set of tradeoffs and boundaries_. This does at least three things for your discourse:

1. It makes your goals and intentions explicit. This helps reach audiences that share those specific trade-off decisions and definitions of essentiality, while averting negative experiences for those whose definition of what is minimal disagrees with your own.
2. It requires you to understand or acknowledge viewpoints other than your own. Why might a user who's very different from me not like this tool? We should not be hubristic about our software; nothing is the best for everyone.
3. It guides contributors to the software in working according to the actual principles that underlie its design.

---

I want to be clear that I am in no way advocating against building software that does just enough, that has a well-defined scope, that is fast and efficient, or that omits capabilities whose impact does not justify their expense. As above, minimalist software may in fact be excellent software.

I only ask that we say what we mean by "just enough"; that we make our tradeoffs explicit; and that in doing so we acknowledge that someone else might make different but equally valid choices.
