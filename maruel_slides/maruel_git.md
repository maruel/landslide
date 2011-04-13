git
===

---

Preamble
=========

## Tips and recipes are using git-svn based chromium workflow as examples.

git makes you feel stupid, by design. It doesn't mean you are, it's just hard to
get to know enough to be efficient, a bit like C++.

This presentation assumes you've already played with git a little and banged
your head on the wall a few times. Otherwise, you may want to review a [visual
git reference](http://marklodato.github.com/visual-git-guide/index-en.html)
first.

Press `t` to see the table of content.

---

Schedule
=========

  - Useful tools
  - Concepts
  - Pipelining
  - Finding lost changes
  - Squashing
  - Reverting a single file
  - Splitting a single commit in two
  - 3 ways push and pull

---

Tools
=====

You _need_ these tools to be efficient.

  - [maruel's bin_pub](http://github.com/maruel/bin_pub) will give you a head
    start on how to setup your configuration, in particular you want
    configs/.gitconfig, configs/.git-prompt.conf, autodiff.
  - [git-prompt](https://github.com/lvv/git-prompt) is extremely useful for bash
    users. It shows the status of your git and svn checkout. The initial cd into
    versioned directory is slow so you may want to disable some functionality.
      - git-prompt is slow on cygwin, borderline usable but I hardly can live
        without it.
  - Make sure bash completion is enabled.
  - [kdiff3](kdiff3) is a great 3-ways merge tool, available on all platforms.

---

Basic concepts
==============

   - Named branches or tags points to a commit hash
   - A commit hash is enough to have all the commit linear history up to the
     initial commit.
   - Commit hash not referenced by any commit referenced by a named branch or
     tag will be deleted on next garbage collection, git gc.
   - A named branch can be reset to arbitrary new hash, which happens when you
     rebase.

If it's still unclear to you, the rest of this document may sound like foreign
language. It'll be easier if you refer back to the topics as you are trying
them, like for instance a pipelined review or squashing a change.

---

Basic concepts (suite)
----------------------

The following assumes you know the aliases in bin_pub:

    st = status
    co = checkout
    ci = commit
    br = branch
    sr = svn rebase

`git ci -a -m.` does a commit with the message ".". It's faster because it's
doesn't brings up the text editor. It adds changes to all tracked files but
_not_ untracked files, e.g. new files. For this, you need to use `git add -A .`

---

Local versus remote
-------------------

It is easy to confuse with local and remote branch. Remote branches on a git
repo are caches of the actual remote branches. Beware of `/` in branch names.
Try this at home to be confused:

    git co -b origin/trunk origin/trunk
    git br -a

To delete the _local_ branch named like a _remote_ branch, use:

    git br -D origin/trunk

When `pull`ing or `fetch`ing, use `--prune` to remove the cache of remotely
deleted branches.

---

Tracking branch
---------------

A tracked branch is the default branch that will be used when `pull`ing.

It's also used by `git-cl` to diff against. You can set a tracking branch with
`br --set-track` or specifying the optional tracking branch when `co -b
<new_branch> <tracked branch>`.

---

Serial vs parallel
------------------

You can do multiple changes in *parallel* if they are independent of each other.
On svn, you can have multiple gcl changes on different files or with multiple
checkouts. You cannot do serialized changes.

On git you can do *serial* changes. This means some changes depends on the
previous changes to be committed. For instance you have the first change
implementing an interface and the second one using it. You cannot commit the
second one before committing the first one.

---

Pipelining
==========

Pipelining is the fact of serializing multiple changes instead of sending them
in parallel. It happens when a change cannot be done before the previous change
is checked in. By pipelining reviews, you reduce the impact of _review latency_
by continuing to work on your next patch. The cost is when changes are requested
on your review, you will get rebase conflicts.

You cannot pipeline with svn, but you can do parallel changes by having multiple
checkouts. On git, parallel changes is simply having 2 unrelated branches based
of master or trunk.

---

Pipelining sample
-----------------

    git co -b 1_foo origin/trunk
    touch bar;  git ci -a -m.
    git cl upload -r foo@chromium.org --send-mail

    git co -b 2_bar
    touch bar;  git ci -a -m.
    # Send the review against the previous branch.
    git cl upload -r foo@chromium.org 1_foo

    git co -b 3_bar
    touch bar; git ci -a -m .
    # Again.
    git cl upload -r foo@chromium.org 2_bar

---

Pipelining sample (part 2)
--------------------------

    # Go back to first branch as reviewer sent his
    # comments.
    git co 1_foo
    # Do silly style nits he requested.
    touch bar
    # Amend the commit to keep the number of commit
    # unchanged in the 'commit log'.
    git ci -a --amend
    # Upload a new patchset for rietveld issue
    # associated with 1_foo.
    git cl upload

---

Pipelining sample (part 3)
--------------------------

Now that the original branch `1_foo` doesn't point to the original hash but a
new totally unrelated hash, we need to rebase `2_bar` against the _new_ `1_foo`:

    # Rebase the branch.
    git co 2_bar
    git rebase 1_foo
    # Only if conflicts.
    git mergetool
    git rebase --continue
    # Now 2_bar is rebased against the 'new'
    # 1_foo. Upload a new patchset.
    git cl upload 1_foo

---

Finding lost changes
====================

It's easy to delete a branch by error. But git is not stupid and doesn't delete
information.

Rebasing is somehow creating a new branch and deleting the old one, if your
rebase was done incorrectly, you may want to find the previous commit tree.

    git reflog
    git co <hash>
    git co -b forgotten_branch

Or use the format `HEAD@{3}` or `ORIG_HEAD`. Google for more details. You can
revert the last 3 commits by checking out `HEAD~3` or `HEAD^^^`.

---

Squashing
=========

_Committing often_ is important with git. Often, commits don't stand on their
own, they are worth squashing together.

    # Make sure rebase is clean.
    git rebase trunk
    # Rebase in interactive mode.
    git rebase trunk -i
    # Put `s` on every commit you want to squash.
    # Then edit new commit description.

*Warning:* squash and merges don't play well together. git won't let
you squash multiple changes with a merge in the lot. You'll need to squash the
merge on its own.

---

Manual Squashing (example)
-------------------

    $ git rebase -i trunk

Which brings up:

    pick 49a8dd7 Force all unit tests to run.
    pick 2c86ef4 .
    pick 0ab32a4 .
    pick 742d03d .

To squash effectively, replace the text to:

    pick 49a8dd7 Force all unit tests to run.
    s 2c86ef4 .
    s 0ab32a4 .
    s 742d03d .

---

Automatic squashing
-------------------

Instead, you can simply use my `git squash` alias from
[bin_pub/configs/.gitconfig](
https://github.com/maruel/bin_pub/blob/master/configs/.gitconfig).

This will do the same as the manual example from the last slide. Manual
squashing is still useful to cherry-pick a change _out_ of your squash.

---

Merge vs Rebase
===============

General wisdom:

   - Merge = upstream is git
   - Rebase = upstream is svn

Merging keeps the (non-linear) history, rebasing "linearilize" the history,
keeping it simpler but you _must not_ rebase a branch once you've pushed.

You can rebase when `pull`ing with `--rebase`. It's the equivalent of `fetch` &&
`rebase <tracked branch>`.

---

Reverting a single file
=======================

You can simply checkout a single file from another branch.

    git co master -- path/to/screwed.cc
    git ci --amend

The `--` separates branch name from the files list.

You can use wildcards in quotes: `"tools/*.py"`, otherwise bash will interprets
it. It's simpler and safer to checkout than reset.

---

Splitting a commit in 2
=======================

Sometimes you start hacking on a source file to realize it should be sent as two
separate reviews.

To split a single commit in two:

  - Create a new branch against master.
  - Use `add -p` to add _parts of a file_ to the index.
  - `commit` the first part in a named branch without using `-a`.
  - `commit` the remaining in another pipelined branch using `-a`.

---

Splitting a commit in 2 (sample)
--------------------------------

    git co -b 1_foo master
    # Read git merge man page.
    git merge --squash crappy_change
    # Remove everything from the index.
    git reset --mixed
    # Add only stuff you want
    git add -p
    # Do not use -a !
    git ci -m "Part 1"

    git co -b 2_bar
    # Adds unversioned files since
    # reset --mixed will drop them.
    git add -A .
    git ci -m "Part 2"

---

It's warmer in 3 ways
=====================

It's hard to set partners right to achieve a 3 ways but it is useful in
_collaborative_ environment. Examples:

  - Users are fetching chromium.git as the official git-svn clone and want to
    exchange _stuff_.
  - Users are fetching from <http://git.kernel.org> and want to share
    bits of hash.

In that scenario, they can push and pull directly from each others, without
having to access the remote _official_ repository at all. With hashes, they can
confirm the whole history of commit without fear. The trick here is to _merge_
and not _rebase_ so the history relationship is kept.

---

Cloning from multiple repos
---------------------------

Use case: clone the git repo from your workstation to your laptop so you can
work during your MTV visit.

    # Computer #1 (initial setup on workstation)
    git clone \
      http://git.chromium.org/git/chromium.git \
      ~/path/to/src
    # Computer #2 (the laptop)
    git clone computer_1:path/to/src
    # 3rd way.
    git add remote official \
      http://git.chromium.org/git/chromium.git

---

Cloning from multiple repos (suite)
-----------------------------------

    # Now you can sync once in a while from
    # wherever you want.
    git pull official trunk
    # And push a specific branch
    git co awesome
    # 'origin' is the workstation
    git push awesome origin awesome
    # To make sure everything is in order
    git remote -v

This way, you can continue to work on your laptop seamlessly, and push back your
changes to your workstation to continue working once you're back on the ground.

---

Pushing to non-bare repositories
--------------------------------

To push on a repository that has the branch checked out, you'll need to set

    git config receive.denyCurrentBranch = warn

So you will be warned if you push to a repository but it will still let it
through. Once you back at the workstation you will want to `git reset --hard` to
reset the files to match what is in the index.

---

Pushing all branches automatically
----------------------------------

Let's say you have a remote named `workstation` and you are working on your
laptop.

When you push, you want to push all the branches all the time since your
workstaiton is the golden copy, then set this configuration:

    git config remote.workstation.push \
        "+refs/heads/*:refs/remotes/workstation/*

---

Random stuff
============

People working on chromium.git may want to have separate checkouts for their
branches to improve compilation speed; switching branch forces rebuilding a lot
of files; See [git-new-workdir in
contrib](http://git.kernel.org/?p=git/git.git;a=blob;f=contrib/workdir/git-new-workdir)
more details.

