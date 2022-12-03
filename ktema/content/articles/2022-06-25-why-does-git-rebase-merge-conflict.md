+++
title="Why Does `git rebase` Merge Conflict?"
[taxonomies]
categories=["Articles"]
+++

I've got a really ugly branch (`daves-feature`) going. I started my branch from `main`, but later realized it was better suited to be based on `parent`. My commit history looks like this:

```
ac1f97e (HEAD -> daves-feature) Hush, Pyright
1a48f15 Cleanup
c18fe09 Working parallelization with passing tests
b99aef1 Merge
8c048ba (parent) Add multi-status field
30084f1 WIP
c7c4f26 Try a different strategy
77bfbf7 WIP
```

In addition to lots of WIP commits, I've got a merge of my new base branch, `parent`, there in the middle of my commit history. (In retrospect, this was a mistake - I should have rebased _then_). I want to rebase this branch to squash it into a single, clean commit that I can merge into `parent`, the new base branch. Essentially, I'd like my Pull Request to depict the outcome of GitHub's "Squash and Merge" operation.

But when I do `git rebase -i parent`, I get

```
error: could not apply 77bfbf7... WIP
Resolve all conflicts manually, mark them as resolved with
"git add/rm <conflicted_files>", then run "git rebase --continue".
You can instead skip this commit: run "git rebase --skip".
To abort and get back to the state before "git rebase", run "git rebase --abort".
Could not apply 77bfbf7... WIP
```

I can't rebase because although my branch _currently_ does not have merge conflicts, at commit
`77bfbf7`, it did. I resolved those merge conflicts at commit `b99aef1`, when I merged the base branch into my branch. But the rebase applies my commits _in order_ on top of the latest commit on `parent`, which means _my merge conflict resolution is in the wrong place_.

Rewriting this history so that the rebase goes off cleanly is... complicated to say the least, and there's no guarantee it's even possible in every case (for example, what if the merge resolution depends on changes introduced in `77bfbf7`?)

Luckily, there is a way to achieve the high-level objective without having to dance through the commit history:

```
$ git switch parent
$ git switch -c daves-feature-new
$ git merge --squash daves-feature
$ git branch -D daves-feature
$ git branch -m daves-feature
```

I check out the base branch and create a new branch from it, `daves-feature-new`. Then I squash-merge my old branch into that new branch, delete the old branch, and rename the new branch to `daves-feature`. That sets me up with exactly the situation I wanted, a clean, one-commit history with `8c048ba` as the base:

```
$ git diff --oneline
dddcf75 (HEAD -> celery-new) Add Celery
8c048ba (parent) Add multi-status field
```

Shiny. Then I can force-push (subject to all the usual caveats!) with

```
$ git branch --set-upstream-to=origin/daves-feature
$ git push -f
```

And my PR is nice and clean.