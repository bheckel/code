
Post PR Approval:

bob@host MINGW64 /c/Orion/workspace/data/Source/SQL (feature/ORION-31587)
$ git checkout develop
Switched to branch 'develop'
Your branch is up to date with 'origin/develop'.

bob@host MINGW64 /c/Orion/workspace/data/Source/SQL (develop)
$ git pull
remote: Counting objects: 17, done.
remote: Compressing objects: 100% (4/4), done.
remote: Total 17 (delta 13), reused 17 (delta 13), pack-reused 0
Unpacking objects: 100% (17/17), done.
From github.sas.com:orion/data
   8dcbba3a644..07ae678951a  develop    -> origin/develop
Updating 8dcbba3a644..07ae678951a
Fast-forward
 Source/SQL/3.48OrionScripts/3.48_GoLive_Script.sql |  3 +
 .../3.48OrionScripts/ORION-30739_data_change.sql   | 72 ++++++++++++++++++++++
 Source/SQL_Views/RPT_OATS_ACCOUNT_ACTIVITY.sql     | 22 ++++---
 Source/SQL_Views/RPT_OATS_OPP_ACTIVITY.sql         | 26 +++++---
 4 files changed, 107 insertions(+), 16 deletions(-)
 create mode 100644 Source/SQL/3.48OrionScripts/ORION-30739_data_change.sql

bob@host MINGW64 /c/Orion/workspace/data/Source/SQL (develop)
$ git merge --no-ff feature/ORION-31587
Merge made by the 'recursive' strategy.
 .../3.48OrionScripts/ORION-31587_ddl_change.sql    |  12 +
 Source/SQL/SALES_CREDITS.pck                       | 521 +++++++++------------
 Source/SQL/SALES_CREDITS_TYPES.pck                 |  86 ++++
 Source/SQL/USER_ON_CALL.pck                        |  20 +-
 Source/SQL/USER_ON_CALL_TYPES.pck                  |  19 +
 5 files changed, 344 insertions(+), 314 deletions(-)
 create mode 100644 Source/SQL/SALES_CREDITS_TYPES.pck
 create mode 100644 Source/SQL/USER_ON_CALL_TYPES.pck

bob@host MINGW64 /c/Orion/workspace/data/Source/SQL (develop)
$ git push origin develop
Enumerating objects: 13, done.
Counting objects: 100% (13/13), done.
Delta compression using up to 8 threads.
Compressing objects: 100% (5/5), done.
Writing objects: 100% (5/5), 492 bytes | 492.00 KiB/s, done.
Total 5 (delta 4), reused 0 (delta 0)
remote: Resolving deltas: 100% (4/4), completed with 4 local objects.
To github.sas.com:orion/data.git
   07ae678951a..6b7ce657a4d  develop -> develop

---

# New feature branch
git checkout develop
git pull
git branch feature/ORION-26857
git checkout feature/ORION-26857
# or just git checkout -b feature/ORION-26857
git push --set-upstream origin feature/ORION-26857
vi SET_CONTACT_MATCH_CODE.prc
git add . && git commit -m 'ORION-26857: Replace SET_CONTACT_MATCH_CODE DBMS_SQL cursors with SQL and modify INSERT/UPDATE to a MERGE'
git push

---

Approved PR collision https://bocoup.com/blog/git-workflow-walkthrough-merging-pull-requests

# github merge PR button is not available
git checkout master
git fetch origin master
git checkout docs
git merge master
# fix conflict... test code on this feature branch...
git add . && git commit -m 'Fix'
git push
# ...github merge PR button is available now so click it or do:
git checkout master
git pull origin master
git merge --no-ff docs
# Take my master and make it the remote's master
git push origin master
git branch -d docs
git push origin --delete docs

---

# What changed between commits
git log
git difftool b15580136e5 7932c1cd095

---

# The name on the left is your name, and the name on the right is their name.
# Remember that when you run git push, you are using two Gits, with two different
# repositories. You are telling your Git to call up someremote Git. Once your
# Git has the other Git on the Internet-phone (via https or ssh or whatever),
# your Git sends some of your commits to their Git, and then your Git asks them
# to set their branches, usually based on the commits you just sent.
git push someremote branch:branch

---

git stash list
# nothing

git stash save --include-untracked 'sales comp'
# now you can switch branches

# then later
git stash apply stash@{0}
# or
git stash pop 
# to remove stash if no collisions

# delete all stashes
git stash clear

---

# View an older version of a file
git log --name-only --pretty=format:"%h - %an, %ar : %s"
# to find  Source/SQL/SALES_COMP_ACCRUAL.pck is 923ab5b2d98
git show 923ab5b2d98:Source/SQL/SALES_COMP_ACCRUAL.pck
# or gitk /c/Orion/workspace/data/Source/SQL/SALES_COMP_ACCRUAL.pck

---

# Feature Branch Workflow:

# This checks out a branch called marys-feature based on master, and the -b flag
# tells Git to create the branch if it doesn’t already exist. On this branch,
# Mary edits, stages, and commits changes in the usual fashion, building up her
# feature with as many commits as necessary:
git checkout -b marys-feature master

git add <some-file>
git commit

# Push her new feature branch up to the central repository. This serves as a
# convenient backup, but if Mary was collaborating with other developers, this
# would also give them access to her initial commits.

# This command pushes marys-feature to the central repository (origin), and the
# -u flag adds it as a remote tracking branch. After setting up the tracking
# branch, Mary can call git push without any parameters to push her feature.
git push -u origin marys-feature
# same?
# git push --set-upstream origin feature/ORION-26857

# Before merging it into master, she needs to file a pull request letting the
# rest of the team know she's done. But first, she should make sure the central
# repository has her most recent commits:

git push

# Then she files the pull request in her Git GUI asking to merge marys-feature
# into master, and team members will be notified automatically

# Once Bill is ready to accept the pull request, someone needs to merge the
# feature into the stable project (this can be done by either Bill or Mary):
git checkout master
git pull
git pull origin marys-feature
git push

# This process often results in a merge commit. Some developers like this because
# it's like a symbolic joining of the feature with the rest of the code base. 

---

# https://www.atlassian.com/git/tutorials/syncing
# Upload the local state of <branch-name> to the remote repository specified by
# <remote-name> (i.e. URL shortcut origin) 
git push <remote-name> <branch-name>

---

xoheck@xxxx523 MINGW64 /c/Orion/workspace/data (feature/ORION-31044)
$ git remote show origin
* remote origin
  Fetch URL: git@github.sas.com:orion/data.git
  Push  URL: git@github.sas.com:orion/data.git
  HEAD branch: develop
  Remote branches:
    develop             tracked
    feature/ORION-30886 tracked
    feature/ORION-31044 tracked
    feature/ORION-31487 tracked
    feature/ORION-31587 tracked
    master              tracked
  Local branches configured for 'git pull':
    develop             merges with remote develop
    feature/ORION-31044 merges with remote feature/ORION-31044
    feature/ORION-31587 merges with remote feature/ORION-31587
  Local refs configured for 'git push':
    develop             pushes to develop             (local out of date)
    feature/ORION-31044 pushes to feature/ORION-31044 (up to date)
    feature/ORION-31587 pushes to feature/ORION-31587 (up to date)

---

??
git pull origin develop  =  pull FROM o to   d
git push origin develop  =  push TO   o from d

---

04-Sep-18 https://gist.github.com/blackfalcon/8428401

git checkout develop
git pull  # or git pull origin develop
git checkout -b feature/ORION-31044
vi Source/SQL_Views/rpt_account_address.sql
git add . && git commit -m 'ORION-31044: Add View to Include Addresses for Accounts Not Used in Orion'
git push --set-upstream origin feature/ORION-31044  # first time only then just  git push
# click button for approval ...
# ... approved
???git pull origin develop
git checkout develop
git pull origin develop
git merge --no-ff feature/ORION-31044
# Take my develop and make it the remote's develop
git push origin develop  # or same: git push origin develop:develop or same git push
git branch -d feature/ORION-31044
git push origin --delete feature/ORION-31044  # if not using github del button
git branch -r  # or  git ls-remote origin  to confirm
git fetch -p  # prune other's deleted branches

---

WRONG??

# Ready to send but prior to any committing:
git stash

# Update the branch to the latest code:
git pull

# Running git merge with non-trivial uncommitted changes is discouraged i.e. git merge --abort may fail
# Merge your local changes into the latest code:
git stash apply

# Add, commit your changes:
git add . && git commit -m 'ORION-31587: Modify packages to avoid ORA-04068'

# Push local commits:
git push origin HEAD:feature/ORION-31587

# Click pull request button

# After approval Click 'Merge pull request' button

# ???
# one-time setup branch:
git clone git@github.sas.com:orion/data.git
git branch feature/ORION-31587
git checkout feature/ORION-31587
vi .git/info/exclude
git add . && git commit -m 'ORION-31587: Modify packages to avoid ORA-04068'
# confirm
git config --local -e
git branch --set-upstream-to=origin/develop feature/ORION-31587
git pull
git push origin HEAD:feature/ORION-31587

---

Use .git/info/exclude instead of .gitignore

---

28-Aug-18 feature branch workflow
  737  2018-08-28 09:33:09 rm -rf misc
  738  2018-08-28 09:33:14 git clone git@github.com:bheckel/misc.git
  739  2018-08-28 09:33:17 cd misc/
  740  2018-08-28 09:33:40 git branch test4
  741  2018-08-28 09:33:50 git checkout test4
  742  2018-08-28 09:33:54 vi README.md
  743  2018-08-28 09:35:03 git add . && git commit -m 'test4 with branch'
  744  2018-08-28 09:35:06 gs
  747  2018-08-28 09:41:29 git branch --set-upstream-to=origin/master test4
  748  2018-08-28 09:41:32 git config --local -e
  749  2018-08-28 09:42:51 git ls-remote origin
  750  2018-08-28 09:43:39 git pull
  752  2018-08-28 09:48:46 git push origin HEAD:test4
  753  2018-08-28 09:48:59 git ls-remote origin
  754  2018-08-28 09:58:13 vi README.md
  755  2018-08-28 09:58:51 git add . && git commit -m 'test4 branch postpullrequest'
  757  2018-08-28 09:59:04 git pull
  758  2018-08-28 09:59:13 git push origin HEAD:test4


27-Aug-18 bad
  675  2018-08-27 15:53:04 git clone git://github.com/bheckel/misc.git
  677  2018-08-27 15:53:31 cd misc
  git remote -v
  678  2018-08-27 15:53:36 git branch test2
  679  2018-08-27 15:53:42 git checkout test2
  681  2018-08-27 15:55:25 cat .git/config
  685  2018-08-27 15:57:04 git push -u origin test2
# 'you cant push'
git config --local -e
change to:
url = git@github.com:bheckel/misc.git
  686  2018-08-27 15:57:36 git remote add originx git@github.com:bheckel/misc.git
  688  2018-08-27 15:57:52 git push -u originx test2
  689  2018-08-27 15:58:23 vi README.md
  691  2018-08-27 15:58:50 git add .
  690  2018-08-27 15:58:43 git commit -m 'test2 hack'
  693  2018-08-27 15:59:43 git push -u originx test2
  696  2018-08-27 16:00:41 git push
  697  2018-08-27 16:02:46 git checkout master
  698  2018-08-27 16:02:53 git fetch origin
  699  2018-08-27 16:03:18 git checkout -b test originx/test2
  ??701  2018-08-27 16:03:38 git merge master
  702  2018-08-27 16:03:55 git checkout master
  703  2018-08-27 16:04:07 git merge test2
  705  2018-08-27 16:04:24 git push originx master
  706  2018-08-27 16:05:57 git pull
  708  2018-08-27 16:06:25 git branch -a

---

git config --local -e

edit .git/config:

[branch "feature/ORION-31587"]
         remote = origin
         merge = refs/heads/feature/ORION-31587

---

# Best passwordless ssh
ssh-copy-id -i ~/.ssh/id_rsa.pub bheckel@sas-01.twa.taeb.com

---

https://github.com/new

…or create a new repository on the command line

echo "# code" >> README.md
git init
git add README.md
git commit -m "first commit"
git remote add origin git@github.com:bheckel/code.git
git push -u origin master

the above defaulted to http and user password prompting:
0 bheckel@appa[master] code/ Fri Dec 15 11:58:47  
$ git remote -v
origin  https://github.com/bheckel/code.git (fetch)
origin  https://github.com/bheckel/code.git (push)

so changed to this:
0 bheckel@appa[master] code/ Fri Dec 15 12:03:37  
$ git remote set-url origin git@github.com:bheckel/code.git
$ git remote -v
origin  git@github.com:bheckel/code.git (fetch)
origin  git@github.com:bheckel/code.git (push)

---

Compare what changed locally prior to push:
git show  # one big less-like context diff
git difftool  # vimdiff one file at a time

Which files were affected in each commit:
git log --date=short --name-only

---

# Restore a single deleted file
wget https://raw.githubusercontent.com/bheckel/transfer/master/whoops.txt

---

# Collaborating on a bugfix:

# Alice:
# It's possible to make changes to the working directory before creating a new
# branch, as long as those changes haven't yet been committed.
vi index.htm
git checkout -b fix-trademark
git commit -am "Add placeholders for the trademark fix"
git push -u origin fix-trademark

# MadHatter:
git pull
# nothing-because the branch is associated with the remote origin, such branches aren't displayed by default
git branch
git branch -a  # show list of local & remote
git checkout fix-trademark
git diff master  # what did Alice's comment say
vi index.htm
git commit -am "Fix trademark character display" && git push

# Alice:
git pull
# looks good
git checkout master
git merge fix-trademark
git push  # the remote master branch on GitHub gets the fix

# MadHatter:
git pull

---

Git status sequence for a changing file:

                      git add           git commit              git push
 UNTRACKED/UNSTAGED -----------> STAGED ----------> LOCAL REPO -------------> REMOTE REPO


---

# Instructions - work on an existing remote repo (after clicking New, naming and allowing a README.md to be created by github)
cd
git clone git://github.com/bheckel/transfer.git
cd transfer/
vi wtf.txt
# Copy sas0's id_rsa.pub to github.com Settings::Keys if first time:
# "You can't push to git://github.com/bheckel/transfer.git..." error
git remote set-url origin git@github.com:bheckel/transfer.git 
git remote -v  # list your remote aliases
git add . 
git commit -m 'initial'
git push origin master

---

cd ~/Downloads
echo '*' > .gitignore
git init 
git remote add origin git@github.com:bheckel/transfer.git
git add -f c.NEW
git commit -m 'initial'
git push origin master  # spews ERROR b/c i created repo on appa then did the github.com clicks
git pull origin master  # so do this (README.md downloads)
git push origin master  # c.NEW uploads

---

# Onetime setup edits ~/.gitconfig:
git config --global user.name "Robert S. Heckel Jr."
git config --global user.email rsh@rshdev.com
git config --global color.status auto
git config --global color.diff auto
# Optional:
git config --global core.editor vim
git config --global merge.tool vimdiff
git config --safecrlf yes
git config --global color.ui true
# F=quit if 1 screen, S=make less wrap, X=handle control chars
git config --global --replace-all core.pager 'less -+F -+S -+X'
###git config --autocrlf yes  # Windows
###git config --autocrlf no  # Unix
git config -l
# or all at once:
git config --global user.name "Robert S. Heckel Jr." && git config --global user.email rsh@rshdev.com && git config --global color.status auto && git config --global color.diff auto && git config --global core.editor vim && git config --global merge.tool vimdiff

# Current project (only edits .git/config):
git config color.ui false

git config --help
# or
git help config
# or 
man git-config

$ cat ~/project/.gitignore
*.a       # no .a files
*.[oa]    # or .o and .a 
!lib.a    # but do track lib.a, even though you're ignoring .a files above
/TODO     # only ignore the root TODO file, not subdir/TODO
build/    # ignore all files in the build/ directory
doc/*.txt # ignore doc/notes.txt, but not doc/server/arch.txt
*~

=======
$ cd datapost/
$ git init
$ git add .  # all files & subdirectories in pwd
$ git commit -m 'initial'
$ git status
$ vi t2  # new file
$ git status
$ git diff  # for anything uncommitted
$ git log  # to get hashes
$ git diff 043e478  # or git diff bc2b733 043e478 to be verbose
$ git commit -am 'first'
$ git status
$ vi cfg/newbie  # new file
$ git add .  # gets subdirs
$ git status
$ vi t2
$ git status
$ git commit -am '2nd'
# On branch master
nothing to commit (working directory clean)
$ git show  # a last commit diff
$ git fshow # list last commit files
$ git branch  # print which branches exist git branch -v (or branch -rv if remotes) for more detail
$ git branch ccf1  # !!don't forget next command or you'll be editing the parent!!
$ git checkout ccf1
$ vi cfg/DataPost_Configuration.xml
$ >code/NEWFCCF1
$ git status
$ git add .
$ git commit -am 'first on ccf1branch'
$ git checkout master
$ >data/foofrommaster
$ git add . && git commit -am 'another master chg b4 merge'
$ git checkout master
$ git merge ccf1
$ git branch -D ccf1  # delete unmerged branch
$ git log
$ git ls-files  # list which files are tracked under git source control not just staged
$ git count-objects
$ git gc  # compress to save space
$ git count-objects
$ git reflog  # log of where your HEAD and branch references have been for the last few months
=======

# Rename move local (current) branch:
git branch -m mynewbranchname

git branch -d ccf1  # delete branch remove branch

# Undo, delete, destroy, last commit:
git reset --hard HEAD^
git reset --hard HEAD~  # same
git reset --hard HEAD~1  # same

# Edit modify rewrite rename existing git commit message.  Actually will
# replace the old commit with a new commit incorporating your changes, giving
# you a chance to edit the old commit message first.
git commit --amend -m 'change your previous last wrong commit message to this'

# Download a complete github project into a non-git-aware directory:
git clone git://github.com/bheckel/dotfiles.git  
# ...which dumps into ./dotfiles/ unless you do something like:
git clone git://github.com/bheckel/dotfiles.git dotfiles-copy

# Simple stash: working on mywipbranch and need to fix an emergency bug so do:
git stash  # or git stash save "work in progress for foo feature"
git checkout master
# .. do stuff to prod branch's b21_0003e.sas ... then
git add code/b21_0003e.sas && git commit -m 'bugfix on master'
# ...now we're ready to leave this emergency branch...
# DO NOT FORGET TO SWITCH BRANCHES BACK!!!
# DO NOT FORGET TO SWITCH BRANCHES BACK!!!
# DO NOT FORGET TO SWITCH BRANCHES BACK!!!
git checkout mywipbranch  # use  git checkout -f  when you forget this step and fup prod
# DO NOT FORGET TO SWITCH BRANCHES BACK!!!
# DO NOT FORGET TO SWITCH BRANCHES BACK!!!
# DO NOT FORGET TO SWITCH BRANCHES BACK!!!
git stash list
git stash pop  # most recent

# More complex stash:
# Do not use stash -u unless all files are being tracked! Untrackeds get whacked.
git stash  # or if >1 stash expected:  git stash save 'your message here'
git checkout master
# ...do stuff to master branch and commit...
git checkout myotherbranch
git stash list
git stash apply stash@{1}  # or just:  git stash apply  or git stash pop
git stash clear  # deletes ALL stashes

# Poor man's snapshot prior to doing something dangerous
git stash save && git stash apply

# Add new file to repo (need -f for my ~/code/misccode/ because .gitignore holds '*'):
git add _tmux.conf && git commit -m'initial' && git push origin master

# Remove existing file from repo:
git rm dotfiles.sh && git commit -m'remove' && git push origin master

# Get "HTTPS clone URL" from github page first then:
git clone https://github.com/grayghostvisuals/Practice-Git.git

# Github
# If you've already forked in the past:
git clone https://github.com/bheckel/Practice-Git.git
cd Practice-Git
#                             any name
git remote add --track master upstream git://github.com/grayghostvisuals/Practice-Git.git
# Next two are instead of  git pull:
git fetch upstream  # no apparent changes yet
git merge upstream/master
git branch july13
git checkout july13
# ...make 3 changes to be squashed into one...
# DO NOT REBASE COMMITS THAT YOU HAVE PUSHED TO A PUBLIC REPOSITORY.
# Normally, rebasing replays changes from one line of work onto another in the
# order they were introduced, whereas merging takes the endpoints and merges
# them together but here we're just compressing log entries.
# It's "~3" because we're trying to edit the last three commits; but keep in mind
# that we're actually designating four commits ago, the parent of the last
# commit you want to edit:
git rebase -i HEAD~3  
# ...now change the 'pick' for the commit(s) to squash into the other (don't
# touch the commit msgs yet)
# Then in the resulting commit screen, save your preferred commit message (or
# just keep all 3).
# For no good reason it's likely you'll need to do this one time to avoid https
# password prompts:
git config remote.origin.url git@github.com:bheckel/Practice-Git.git
git push origin july13  # your github is updated
# base fork is grayghost/Practice-Git, base master and head fork is
# bheckel/Practice-Git, compare july13.  Click PR link and wait for Dennis
git checkout master  # ok to drop july13 branch i think
git fetch upstream
git merge upstream/master  # syncronized with my recent hacks

# Are you working on a project that uses some other version control system, and
# you sorely miss Git? Then initialize a Git repository in your working directory:
$ git init
$ git add .
$ git commit -m "Initial commit"
$ git clone . /some/new/private/directory  # a local clone
# Now go to the new directory and work there instead.  Once in a while, you'll
# want to sync with everyone else, in which case cd to the original directory,
# sync using the other version control system then:
$ git commit -am "Sync with everyone else and their SCM tool"
# Then cd back to your private directory and run:
$ git pull  # their changes to your private
# After *you* later make changes in private, cd back to the original dir and
# pull (don't use push from private):
$ git pull /some/new/private/directory
# Then use their SCM to merge that change

# Instructions - create new project (master) after all the ssh setup work is done on github.com
# https://github.com/new to name it
# (origin):
git init
git remote add origin git@github.com:bheckel/test.git
touch README.md
git add README.md  # use git add -f README.md to force add if it's excluded by .gitignore
git commit -m 'first commit'
git push -u origin master
# ...now it's on github
#
git remote -v  # list your remote aliases like these:
# origin	git@github.com:bheckel/dotfiles.git (fetch)
# origin	git@github.com:bheckel/dotfiles.git (push)
#
# ...make changes to local files (master)...
git push origin master
# e.g. ssh-add && git add _bashrc && git commit -m 'mod' && git push origin master

# ...then you accidentally delete the whole repo and want it restored to a new dir:
cd ~/projects/git  # no git init, project will create ~/project/git/test/
git clone git://github.com/bheckel/test.git
# ...new edits...
git add dotone && git commit -m 'chaos' && git push git@github.com:bheckel/test.git master

# Temporarily ignore a previously committed, i.e. tracked, file temporarily (not
# using a .gitignore approach):
git update-index --assume-unchanged foo.txt
# ...commit...
git update-index --no-assume-unchanged foo.txt

# After adding a new filename (that you're already tracking) to .gitignore must
# do this to stop it from continuing to appear:
git rm --cached foo.txt
git ls-files  # verify foo.txt is gone (but still exists on the filesystem)

# Usually this can't be done with networked server repos (so see git push but
# it's non-trivial):
cd ..
git clone hello cloned_hello
cd cloned_hello
git fetch  # no merges occur automatically so next must...
git merge origin/master  # ...now it's there
# or to combine the two steps:
git pull

git log --oneline
git log --pretty=oneline  # not exactly pretty, just shows full hash
git log --graph --pretty=oneline --abbrev-commit 
git log --all --pretty=format:"%h %cd %s (%an)" --since='7 days ago'
git log --since='6 weeks ago' --grep='LADD'
# best
git log --pretty=format:"%h %ad | %s%d [%an]" --graph --date=short

# Unstage a new file:
git reset HEAD oops.txt
# Revert, throw away, discard changes since last commit:
git checkout -- oops.txt  # BEST single file trash changes for unstaged file
git checkout .   # ALL changes that are not staged for commit
git checkout -f  # ALL changes, good after accidental unstash in wrong branch
# or if some files are staged and you want to keep those only but abandon
# the "not staged for commit" ones (untried):
git stash save --keep-index && git stash drop
git stash
# Drop the last stash - when no <stash> is given, it removes the latest one. i.e. stash@{0}
git stash drop

git reflog  # see all branch changes from way back

# Poke around in the past, revert to a specific old checkin TEMPORARILY from
# mynormalbranch without wasting time branching and branch deleting.
# If you don't know the SHA1 or the tag name, do this first:
git log --pretty=format:"%h %ad | %s%d [%an]" --graph --date=short
git checkout 9deec7a  # detached HEAD
# ...poking finished...
git checkout mynormalbranch

# If you only know the topic but want the SHA1:
git rev-parse sas93branch

# Revert to specific checkin, tossing later one(s)...
git log --pretty=format:"%h %ad | %s%d [%an]" --graph --date=short
# ...choose hash of commit to revert to (i.e. land in)
git reset --hard 4171fb3

# New branch on the fly without jumping to it:
git branch mynewbranch master  # branch from a specific branch in this case master
git branch mynewbranch 2f13ab6  # branch from a specific commit

$ git checkout master  # branch switch
$ git merge ccf1

# Merge collision CONFLICT - edit out the git <<< (theirs) >>>(yours) stuff in
foo.txt, choosing which edit to keep then  git add foo.txt

# View a merge conflict (don't use for binary collisions!):
git show :1:code/_ADO_LIFT.qry  # common base
git show :2:code/_ADO_LIFT.qry  # ours
git show :3:code/_ADO_LIFT.qry  # theirs
# Better merge conflict resolution if vim is set as difftool:
git mergetool
# Edit/delete lines you don't want
rmv _bashrc.orig

# Diff a merge collision in vim (if config is setup correctly) but must save
# as code/_ADO_LIFT.qry when done prior to commit:
git difftool :2:code/_ADO_LIFT.qry :3:code/_ADO_LIFT.qry

git show :2:code/_ADO_LIFT.qry >| code/_ADO_LIFT.qry  # use our version
git add code/_ADO_LIFT.qry
git commit -am 'post semi-manual merge'

# Better if using v1.6.1+.  Assumes we're in committed master branch
git checkout --ours cfg/DataPost_Configuration.xml  # use master
# or 
git checkout --theirs cfg/DataPost_Configuration.xml  # use non-master
git commit -am 'post merge collision - just use theirs'

# or give up
git merge --abort

# Abandon everything since your last commit; this command can be DANGEROUS. But
# if merging has resulted in conflicts and you'd like to just forget about the
# merge, this command will do that.
git reset --hard

# Use git's move instead of OS'. Also can rename.
git mv readme.txt lib/read.me.txt

# Need the backslash, git does its own expansions
git rm log/\*.log
# Remove an accidentally staged file.  Or keep the file in your working tree
# but remove it from your staging area. In other words, you may want to keep
# the file on your hard drive but not have Git track it anymore. This is
# particularly useful if you forgot to add something to your .gitignore file
# and accidentally added it, like a large log file 
git rm --cached big.log

# Delete throw away branch after merge
git branch -d experimental  # or -D if unmerged

git tag 2.0
git tag mystable1tag 1b2e1d63ff  # create "lightweight" tag
git show 2.0
git show HEAD^:path/to/file

# View old version of file from different branch or commit (in pager):
git show eacbd91:code/ods_0002e.sas

############################### COMPARE / REPLACE ##############################################
# Compare specific file in current branch to another branch (then :%diffput etc):
git difftool anotherbranch code/DataPost_Trend.sas
# or
# Compare old version of file from different commit to this commit - current (hash-less) commit must come 2nd!!:
git difftool eacbd91:code/ods_0002e.sas code/ods_0002e.sas
# or
# Compare, sync, all files between 2 commits in same or in any 2 branches:
git difftool 10ed0d7 bd37098
git difftool foo bar
# ...then use vim's dp command to update the lefthand version or, less usefully...
# Replace a single file with a copy from another branch.  We're in master and want the version from anotherbranch:
#            _____________ branch, not a commit!
git checkout anotherbranch code/DataPost_Trend.sas
# Verify by comparing previous commit to the newly replaced file (f8a79b8 is the previous commit on current branch):
git difftool f8a79b8
# If you change your mind after difftool, unstage & restore old:
git reset HEAD code/DataPost_Trend.sas
git checkout -- code/DataPost_Trend.sas  # sometimes not needed-why??
############################### COMPARE / REPLACE ##############################################

# Show files touched in this commit (via custom .gitconfig alias:  fshow = ! sh -c 'git show --pretty="format:" --name-only $1 | grep -v "^$" | uniq | sed -e "s#^#`git rev-parse --show-toplevel`/#"' - ):
git fshow 5fcb8eb  # hash is optional for last commit
# Using custom alias specify a range of commits:
git fshow sas93@{3.days.ago}
git fshow master..junk  # files updated in junk since branching

# Compare files across branches and commits. This fails unless file is in
# previous master commit (fatal: Path 'cfg/Configuration.xml' exists on disk,
# but not in 'master'.) - use  git fshow master  to check.
git difftool master:cfg/Configuration.xml 5fcb8eb:cfg/Configuration.xml
git difftool master:cfg/Configuration.xml trip:cfg/Configuration.xml

# Canonical yoniso to github
cd ~/code/misccode
git branch -rv
gs|grep modif  # what has changed then list them here:
#                                                                   github   PC
git add _bashrc _vimrc oneliners && git commit -m 'mod' && git push origin master

# Commit w/o -m to start editing in vim.  Then a blank line separates subject from details in git log

# Dry run (-n) deletion of untracked files including ones in .gitignore (-x):
git clean -n -d -x .

# Local squash the previous (whoops) commit that should have been done in the 1st commit (hide your whoops):
git rebase -i HEAD~2  # last two commits will appear in picklist
replace 'pick' with 's' for the last commit, :wq
delete the comment from the whoops commit, :wq
# Now only the first commit and its comment appears in git log

---

github config
on yoniso 09-Feb-12

sudo apt-get install git-core git-gui git-doc

cd ~/.ssh

ssh-keygen -t rsa -C "b.heckel@gmail.com"

paste id_rsa.pub into webform

git config --global user.name "Bob Heckel"
git config --global user.email "rsh@rshdev.com"

get dcc... from website
git config --global github.token dcc4109809ea83ef65c8dc1bac431439
